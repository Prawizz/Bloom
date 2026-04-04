import SwiftUI

struct CustomNavBar: View {
    @Binding var selectedTab: Int
    
    let icons = ["house.fill", "calendar", "square.and.pencil", "chart.bar", "person.circle.fill"]
    
    let titles = ["Home", "Calendar", "Journal", "Analysis", "Profile"]
    
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(0..<icons.count, id: \.self) { index in
                
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        
                        ZStack {
                            if selectedTab == index {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("SoftPink").opacity(0.25))
                                    .frame(width: 55, height: 45)
                                    .matchedGeometryEffect(id: "TAB", in: namespace)
                            }
                            VStack{
                                Image(systemName: icons[index])
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(
                                        selectedTab == index
                                        ? Color.black
                                        : Color.gray.opacity(0.6)
                                    )
                                
                                Text(titles[index])
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(
                                        selectedTab == index
                                        ? Color.black
                                        : Color.gray.opacity(0.6)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.9))
                .background(.ultraThinMaterial)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 4)
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}

#Preview {
    MainTabView()
}
