import SwiftUI

struct CustomerShopView: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        VStack {
            ShopHeader(name: shop.name,
                       description: shop.description,
                       imageUrl: shop.imageURL)
            Spacer()
            ShopStatus(shop: shop)
            Spacer()
            ShopProductsList(shop: shop)
        }
    }
}

struct ShopStatus: View {
    var shop: Shop
    var body: some View {
        if shop.isClosed {
            Text("This shop is currently closed. You may not be able to place orders.")
        }
    }
}

struct ShopProductsList: View {
    @EnvironmentObject var viewModel: CustomerViewModel
    var shop: Shop

    var body: some View {
        if (!viewModel.products.contains(where: { $0.shopName == shop.name })) {
            Text("This shop has no products... yet!")
            Spacer()
        } else {
            Text("Menu")
                .font(.appTitle)
            List {
                ForEach(viewModel.products.filter({ $0.shopName == shop.name })) { product in
                    if shop.isClosed {
                        ProductListView(product: product).environmentObject(viewModel)
                    } else {
                        NavigationLink(destination: ProductView(product: product)) {
                            ProductListView(product: product).environmentObject(viewModel)
                        }
                    }
                }
            }
        }
    }
}

struct CustomerShopView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CustomerViewModel()
        let sampleShop = viewModel.shops.first(where: { shop in
            shop.name == "Gong Cha"
        })
        CustomerShopView(shop: sampleShop!).environmentObject(viewModel)
    }
}
