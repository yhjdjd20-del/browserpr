import UIKit

extension UIView {
    // Пружинная анимация
    func springAnimate(duration: TimeInterval = 0.5, delay: TimeInterval = 0, damping: CGFloat = 0.7, velocity: CGFloat = 0.5, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: .curveEaseInOut,
            animations: animations,
            completion: completion
        )
    }

    // Анимация затухания
    func fadeIn(duration: TimeInterval = 0.3) {
        alpha = 0
        UIView.animate(withDuration: duration) { self.alpha = 1 }
    }

    func fadeOut(duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) { self.alpha = 0 }
    }

    // Анимация скейла
    func popIn(duration: TimeInterval = 0.4) {
        transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        alpha = 0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }

    // Анимация пульсации
    func pulse(duration: TimeInterval = 0.8) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.fromValue = 1.0
        animation.toValue = 1.15
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "pulse")
    }

    // Анимация тряски
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.duration = 0.3
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "shake")
    }

    // Анимация поворота (загрузка)
    func startRotating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: "rotation")
    }

    func stopRotating() {
        layer.removeAnimation(forKey: "rotation")
    }

    // Анимация изменения размера
    func scaleTo(_ scale: CGFloat, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
