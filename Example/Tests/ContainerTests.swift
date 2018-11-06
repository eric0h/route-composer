import UIKit
import XCTest
@testable import RouteComposer

class ContainerTests: XCTestCase {

    func testChildViewControllersBuild() {
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushToNavigation()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushToNavigation()))!))
        try? prepare(children: &children)
        guard let childrenControllers = try? ChildCoordinator(childFactories: children).build(with: nil) else {
            XCTAssert(false, "Unable to build children view controllers")
            return
        }
        XCTAssertEqual(childrenControllers.count, 2)
    }

    func testNavigationControllerContainer() {
        let container = NavigationControllerFactory<Any?>()
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushToNavigation()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushToNavigation()))!))
        try? prepare(children: &children)
        guard let containerViewController = try? container.build(with: nil, integrating: ChildCoordinator(childFactories: children)) else {
            XCTAssert(false, "Unable to build UINavigationController")
            return
        }
        XCTAssertEqual(containerViewController.children.count, 2)
    }

    func testNavigationControllerContainer2() {
        let container = NavigationControllerFactory<Any?>()
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushToNavigation()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UINavigationController.pushReplacingLast()))!))
        try? prepare(children: &children)
        guard let containerViewController = try? container.build(with: nil, integrating: ChildCoordinator(childFactories: children)) else {
            XCTAssert(false, "Unable to build UINavigationController")
            return
        }
        XCTAssertEqual(containerViewController.children.count, 1)
    }

    func testTabBarControllerContainer() {
        let container = TabBarControllerFactory<Any?>()
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab()))!))
        try? prepare(children: &children)
        guard let containerViewController = try? container.build(with: nil, integrating: ChildCoordinator(childFactories: children)) else {
            XCTAssert(false, "Unable to build UITabBarController")
            return
        }
        XCTAssertEqual(containerViewController.children.count, 2)
    }

    func testSplitControllerContainer() {
        let container = SplitControllerFactory<Any?>()
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UISplitViewController.setAsMaster()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UISplitViewController.pushToDetails()))!))
        try? prepare(children: &children)
        guard let containerViewController = try? container.build(with: nil, integrating: ChildCoordinator(childFactories: children)) else {
            XCTAssert(false, "Unable to build UISplitViewController")
            return
        }
        XCTAssertEqual(containerViewController.children.count, 2)
    }

    func testCompleteFactory() {
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab()))!))
        try? prepare(children: &children)
        let factory = CompleteFactory(factory: TabBarControllerFactory(), childFactories: children)
        let viewController = try? factory.build(with: nil)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.viewControllers?.count, 2)
    }

    func testCompleteFactoryPrepareMethod() {

        class EmptyFactory: Factory {

            var prepareCount = 0

            init() {
            }

            func prepare(with context: Context) throws {
                prepareCount += 1
            }

            func build(with context: Any?) throws -> UIViewController {
                return UIViewController()
            }

        }

        let childFactory1 = EmptyFactory()
        let childFactory2 = EmptyFactory()
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(childFactory1, action: ContainerActionBox(UITabBarController.addTab()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(childFactory2, action: ContainerActionBox(UITabBarController.addTab()))!))
        var factory = CompleteFactory(factory: TabBarControllerFactory(), childFactories: children)
        try? factory.prepare(with: nil)
        let viewController = try? factory.build(with: nil)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.viewControllers?.count, 2)
        XCTAssertEqual(childFactory1.prepareCount, 1)
        XCTAssertEqual(childFactory2.prepareCount, 1)
    }

    func testCompleteFactorySmartActions() {
        var children: [DelayedIntegrationFactory<Any?>] = []
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab()))!))
        children.append(DelayedIntegrationFactory<Any?>(FactoryBox(EmptyFactory(), action: ContainerActionBox(UITabBarController.addTab(at: 0, replacing: true)))!))
        try? prepare(children: &children)
        let factory = CompleteFactory(factory: TabBarControllerFactory(), childFactories: children)
        let viewController = try? factory.build(with: nil)
        XCTAssertNotNil(viewController)
        XCTAssertEqual(viewController?.viewControllers?.count, 1)
    }

    private func prepare(children: inout [DelayedIntegrationFactory<Any?>]) throws {
        children = try children.map({
            var factory = $0
            try factory.prepare(with: nil)
            return factory
        })
    }

}
