#include <QGuiApplication>
#include <QAnimationDriver>

#include <QQuickWindow>
#include <QQuickRenderControl>
#include <QQuickRenderTarget>
#include <QQuickGraphicsDevice>
#include <QQuickGraphicsConfiguration>
#include <QQuickItem>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QImage>

#include <QtGui/private/qrhi_p.h>
#include <QtQuick/private/qquickrendercontrol_p.h>

// Based on tst_RenderControl::renderAndReadBackWithRhi()
// from qtdeclarative/tests/auto/quick/qquickrendercontrol/tst_qquickrendercontrol.cpp


class AnimationDriver : public QAnimationDriver
{
public:
    AnimationDriver(int msPerStep) : m_step(msPerStep) { }

    void advance() override
    {
        m_elapsed += m_step;
        advanceAnimation();
    }

    qint64 elapsed() const override
    {
        return m_elapsed;
    }

private:
    int m_step;
    qint64 m_elapsed = 0;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    static const int ANIM_ADVANCE_PER_FRAME = 16; // milliseconds
    auto animDriver = new AnimationDriver(ANIM_ADVANCE_PER_FRAME);
    animDriver->install();

    QScopedPointer<QQuickRenderControl> renderControl(new QQuickRenderControl);
    QScopedPointer<QQuickWindow> quickWindow(new QQuickWindow(renderControl.data()));

    QScopedPointer<QQmlEngine> qmlEngine(new QQmlEngine);
    auto qmlPathname = QCoreApplication::arguments().at(1);
    QScopedPointer<QQmlComponent> qmlComponent(new QQmlComponent(qmlEngine.data(), qmlPathname));
    Q_ASSERT(!qmlComponent->isLoading());
    if (qmlComponent->isError()) {
        for (const QQmlError &error : qmlComponent->errors())
            qWarning() << error.url() << error.line() << error;
    }
    Q_ASSERT(!qmlComponent->isError());

    QObject *rootObject = qmlComponent->create();
    if (qmlComponent->isError()) {
        for (const QQmlError &error : qmlComponent->errors())
            qWarning() << error.url() << error.line() << error;
    }
    Q_ASSERT(!qmlComponent->isError());

    QQuickItem *rootItem = qobject_cast<QQuickItem *>(rootObject);
    Q_ASSERT(rootItem);

    quickWindow->contentItem()->setSize(rootItem->size());
    quickWindow->setGeometry(0, 0, rootItem->width(), rootItem->height());

    rootItem->setParentItem(quickWindow->contentItem());

    const bool initSuccess = renderControl->initialize();

    Q_ASSERT(initSuccess);

    // What comes now is technically cheating - as long as QRhi is not a public
    // API this is not something applications can follow doing. However, it
    // allows us to test out the pipeline without having to write 4 different
    // native (Vulkan, Metal, D3D11, OpenGL) implementations of all what's below.

    QQuickRenderControlPrivate *rd = QQuickRenderControlPrivate::get(renderControl.data());
    QRhi *rhi = rd->rhi;
    Q_ASSERT(rhi);

    const QSize size = rootItem->size().toSize();
    QScopedPointer<QRhiTexture> tex(rhi->newTexture(QRhiTexture::RGBA8, size, 1,
                                                    QRhiTexture::RenderTarget | QRhiTexture::UsedAsTransferSource));
    tex->create();

    // depth-stencil is mandatory with RHI, although strictly speaking the
    // scenegraph could operate without one, but it has no means to figure out
    // the lack of a ds buffer, so just be nice and provide one.
    QScopedPointer<QRhiRenderBuffer> ds(rhi->newRenderBuffer(QRhiRenderBuffer::DepthStencil, size, 1));
    ds->create();

    QRhiTextureRenderTargetDescription rtDesc(QRhiColorAttachment(tex.data()));
    rtDesc.setDepthStencilBuffer(ds.data());
    QScopedPointer<QRhiTextureRenderTarget> texRt(rhi->newTextureRenderTarget(rtDesc));
    QScopedPointer<QRhiRenderPassDescriptor> rp(texRt->newCompatibleRenderPassDescriptor());
    texRt->setRenderPassDescriptor(rp.data());
    texRt->create();

    // redirect Qt Quick rendering into our texture
    quickWindow->setRenderTarget(QQuickRenderTarget::fromRhiRenderTarget(texRt.data()));

    QSize currentSize = size;

    for (int frame = 0; frame < 100; ++frame) {
        // have to process events, e.g. to get queued metacalls delivered
        QCoreApplication::processEvents();

        if (frame > 0) {
            // Quick animations will now think that ANIM_ADVANCE_PER_FRAME milliseconds have passed,
            // even though in reality we have a tight loop that generates frames unthrottled.
            animDriver->advance();
        }

        renderControl->polishItems();

        // kick off the next frame on the QRhi (this internally calls QRhi::beginOffscreenFrame())
        renderControl->beginFrame();

        renderControl->sync();
        renderControl->render();

        bool readCompleted = false;
        QRhiReadbackResult readResult;
        QImage result;
        readResult.completed = [&readCompleted, &readResult, &result, &rhi] {
            readCompleted = true;
            QImage wrapperImage(reinterpret_cast<const uchar *>(readResult.data.constData()),
                                readResult.pixelSize.width(), readResult.pixelSize.height(),
                                QImage::Format_RGBA8888_Premultiplied);
            if (rhi->isYUpInFramebuffer())
                result = wrapperImage.mirrored();
            else
                result = wrapperImage.copy();
        };
        QRhiResourceUpdateBatch *readbackBatch = rhi->nextResourceUpdateBatch();
        readbackBatch->readBackTexture(tex.data(), &readResult);
        rd->cb->resourceUpdate(readbackBatch);

        // our frame is done, submit
        renderControl->endFrame();

        // offscreen frames in QRhi are synchronous, meaning the readback has
        // been finished at this point
        Q_ASSERT(readCompleted);

        QImage img = result;
        Q_ASSERT(!img.isNull());

        if (frame == 0 || frame == 25 || frame == 50 || frame == 75 || frame == 99) {
            img.save(qmlPathname + QString::asprintf("-screenshot-%d.png", frame));
        }
    }
    return 0;
}
