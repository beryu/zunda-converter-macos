import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private let serviceProvider = ServiceProvider()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Set up status bar
        statusBarController = StatusBarController()

        // Register macOS Services provider
        // NSPortName in Info.plist must match the name used here
        NSApp.servicesProvider = serviceProvider
        NSRegisterServicesProvider(serviceProvider, "ZundaConverter")
        NSUpdateDynamicServices()
    }
}
