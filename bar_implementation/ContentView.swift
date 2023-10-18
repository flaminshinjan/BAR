import SwiftUI
import BackgroundTasks

struct ContentView: View {
    @State private var data: String = "No Data Yet"

    var body: some View {
        Text(data)
            .onAppear(perform: loadData)
    }

    func loadData() {
        let url = URL(string: "https://webhook.site/e4e067ee-4ac2-4d6e-a738-d65755f8c5f2")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let fetchedData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.data = fetchedData
                }
            }
        }
        task.resume()
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "Stithi.bar-implementation", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let url = URL(string: "https://webhook.site/e4e067ee-4ac2-4d6e-a738-d65755f8c5f2")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                completionHandler(.newData)
            } else if error != nil {
                completionHandler(.failed)
            } else {
                completionHandler(.noData)
            }
        }
        task.resume()
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "Stithi.bar-implementation")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh:", error)
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        let url = URL(string: "https://webhook.site/e4e067ee-4ac2-4d6e-a738-d65755f8c5f2")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                task.setTaskCompleted(success: true)
            } else {
                task.setTaskCompleted(success: false)
            }
        }
        
        task.resume()
        scheduleAppRefresh()
        
        
    }
}
