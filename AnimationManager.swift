import UIKit

class AnimationManager {
    static let shared = AnimationManager()

    // Переход между контроллерами
    func transitionPush(from: UIViewController, to: UIViewController) {
        UIView.transition(
            from: from.view,
            to: to.view,
            duration: 0.4,
            options: [.transitionCrossDissolve, .showHideTransitionViews]
        )
    }

    // Анимированное появление элемента
    func showWithBounce(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.alpha = 0
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            view.transform = .identity
            view.alpha = 1
        }
    }

    // Анимированное скрытие
    func hideWithFade(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.alpha = 0
        }
    }

    // Анимация загрузки (спиннер с градиентом)
    func showLoadingSpinner(on view: UIView) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.startAnimating()
        spinner.tag = 999
    }

    func hideLoadingSpinner(from view: UIView) {
        view.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
    }

    // Анимация переключения вкладок
    func switchTabs(from currentView: UIView, to newView: UIView, in container: UIView) {
        newView.alpha = 0
        newView.transform = CGAffineTransform(translationX: 20, y: 0)
        container.addSubview(newView)

        UIView.animate(withDuration: 0.3) {
            currentView.alpha = 0
            currentView.transform = CGAffineTransform(translationX: -20, y: 0)
            newView.alpha = 1
            newView.transform = .identity
        } completion: { _ in
            currentView.removeFromSuperview()
        }
    }
}
