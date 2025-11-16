//
//  ToastView.swift
//  DailyMoodTracker
//
//  Toast notification for non-intrusive user feedback
//

import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            if isShowing {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text(message)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "b98fa0"), Color(hex: "897691")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 10)
            }

            Spacer()
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isShowing)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content

            ToastView(message: message, icon: icon, isShowing: $isShowing)
        }
        .onChange(of: isShowing) { showing in
            if showing {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        icon: String = "checkmark.circle.fill",
        duration: TimeInterval = 2.0
    ) -> some View {
        self.modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            icon: icon,
            duration: duration
        ))
    }
}
