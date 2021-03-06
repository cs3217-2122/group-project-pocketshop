import SwiftUI

enum ShopProductsViewActiveSheet: Identifiable {
    case editShop, addProduct

    var id: Int {
        hashValue
    }
}

struct ShopProductsView: View {
    @EnvironmentObject var viewModel: VendorViewModel
    @State var activeSheet: ShopProductsViewActiveSheet?
    @State private var showAddProductModal = false
    @State private var showEditProductModal = false
    @State private var showEditShopModal = false
    var shop: Shop

    var body: some View {
        VStack {
            HStack {
                ShopHeader(name: shop.name, location: viewModel.getLocationNameFromId(locationId: shop.locationId),
                           description: shop.description, imageUrl: shop.imageURL)

                Button(action: {
                    activeSheet = .editShop
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
            }

            Spacer()
            ShopOperatingStatusSection(shop: shop)
            Spacer()
            if shop.soldProducts.isEmpty {
                Text("This shop has no products... yet!")
            } else {
                ShopItemsList(shop: shop)
            }
            AddProductButton(activeSheet: $activeSheet)
            Spacer()
        }
        .padding()
        .toolbar {
            EditButton()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .addProduct:
                ShopProductFormView()
                    .environmentObject(viewModel)
            case .editShop:
                ShopEditFormView(viewModel: viewModel, shop: shop)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct ShopHeader: View {
    var name: String
    var location: String
    var description: String
    var imageUrl: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.appTitle)
                    .padding(.bottom)

                Text(location)
                    .font(.appHeadline)
                    .padding(.bottom)

                Text(description)
                    .font(.appBody)
                    .padding(.bottom)
            }
            Spacer()
            URLImage(urlString: imageUrl)
                .scaledToFit()
                .frame(width: 100, height: 100)
        }.padding()
    }
}

struct AddProductButton: View {
    @Binding var activeSheet: ShopProductsViewActiveSheet?

    var body: some View {
        PSButton(title: "Add item/combo to menu") {
            activeSheet = .addProduct
        }
        .buttonStyle(FillButtonStyle())
        .padding(.horizontal)
    }
}

private struct ShopOperatingStatusSection: View {
    var shop: Shop

    var body: some View {
        HStack {
            Text("Shop is currently \(shop.isClosed ? "closed" : "open").")
            ShopOpenCloseButton()
        }
    }
}

private struct ShopItemsList: View {
    @EnvironmentObject var viewModel: VendorViewModel

    var shop: Shop

    var body: some View {
        List {
            ForEach(shop.categories, id: \.self) { shopCategory in
                Section(header: Text(shopCategory.title).font(Font.headline.weight(.black))) {
                    ForEach(viewModel.getOrderedCategoryProducts(category: shopCategory), id: \.self) { product in
                        NavigationLink(destination: ShopProductEditFormView(viewModel: viewModel,
                                                                            product: product)) {
                            ShopProductListView(product: product)
                        }
                    }
                    .onDelete { positions in
                        viewModel.deleteProduct(category: shopCategory, at: positions)
                    }
                    .onMove { indexSet, index in
                        viewModel.moveProducts(category: shopCategory, source: indexSet, destination: index)
                    }
                }
            }
        }
    }
}
