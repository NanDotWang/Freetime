//
//  NotificationsViewController.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/13/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

class NotificationsViewController: UIViewController,
IGListAdapterDataSource,
SegmentedControlSectionControllerDelegate,
FeedDelegate {

    let client: GithubClient
    let selection = SegmentedControlModel(items: [Strings.unread, Strings.all])
    var allNotifications = [NotificationViewModel]()
    var filteredNotifications = [NotificationViewModel]()

    lazy var feed: Feed = { Feed(viewController: self, delegate: self) }()

    init(client: GithubClient) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        feed.viewDidLoad()
        feed.adapter.dataSource = self
    }

    // MARK: Private API

    fileprivate func update(fromNetwork: Bool) {
        let unread = selection.items[selection.selectedIndex] == Strings.unread
        filteredNotifications = filter(notifications: allNotifications, unread: unread)
        feed.finishLoading(fromNetwork: fromNetwork)
    }

    fileprivate func reload() {
        client.requestNotifications(all: true) { result in
            switch result {
            case .success(let notifications):
                self.allNotifications = createNotificationViewModels(
                    containerWidth: self.view.bounds.width,
                    notifications: notifications
                )
            case .failed:
                StatusBar.showNetworkError()
            }
            self.update(fromNetwork: true)
        }
    }

    // MARK: IGListAdapterDataSource

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        guard allNotifications.count > 0 else { return [] }
        return [selection] + filteredNotifications
    }

    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if object is SegmentedControlModel {
            let controller = SegmentedControlSectionController()
            controller.delegate = self
            return controller
        } else {
            return RepoNotificationsSectionController(client: client)
        }
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        switch feed.status {
        case .idle:
            let emptyView = EmptyView()
            emptyView.label.text = NSLocalizedString("Cannot load notifications", comment: "")
            return emptyView
        case .loading:
            return nil
        }
    }

    // MARK: SegmentedControlSectionControllerDelegate

    func didChangeSelection(sectionController: SegmentedControlSectionController, model: SegmentedControlModel) {
        update(fromNetwork: false)
    }

    // MARK: FeedDelegate

    func loadFromNetwork(feed: Feed) {
        reload()
    }

}
