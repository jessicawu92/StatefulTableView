//
//  StatefulTableView+PullToRefresh.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulTableView {
  // MARK: - Pull to refresh

    
  private func endRefreshing() {
    if let delegateMethod = statefulDelegate?.statefulTableViewWillFinishPullToRefresh {
      delegateMethod(self)
    }
    refreshControl.endRefreshing()
  }
    
  func refreshControlValueChanged() {
    if state != .loadingFromPullToRefresh && !state.isLoading {
      if (!triggerPullToRefresh()) {
        endRefreshing()
      }
    } else {
      endRefreshing()
    }
  }

  /**
   Triggers pull to refresh programatically. Also called when the user pulls down to refresh on the tableView.

   - returns: Boolean for success status.
   */
  public func triggerPullToRefresh() -> Bool {
    guard !state.isLoading && canPullToRefresh else { return false }

    self.setState(.loadingFromPullToRefresh, updateView: false, error: nil)

    if let delegate = statefulDelegate {
      delegate.statefulTableViewWillBeginLoadingFromRefresh(tvc: self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        DispatchQueue.main.async(execute: {
          self?.setHasFinishedLoadingFromPullToRefresh(tableIsEmpty, error: errorOrNil)
        })
      })
    }

    refreshControl.beginRefreshing()

    return true
  }

  fileprivate func setHasFinishedLoadingFromPullToRefresh(_ tableIsEmpty: Bool, error: NSError?) {
    guard state == .loadingFromPullToRefresh else { return }
    endRefreshing()

    if tableIsEmpty {
      self.setState(.emptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.idle)
    }
  }
}
