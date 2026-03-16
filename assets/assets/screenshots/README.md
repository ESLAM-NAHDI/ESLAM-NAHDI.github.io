# Screenshots Directory

Place your screen screenshots in this directory.

## Naming Convention
Name your screenshots based on the page name:
- `splash_screen.png` - For Splash Screen
- `login_screen.png` - For Login Screen
- `home_page.png` - For Home Page
- `product_details.png` - For Product Details
- `shopping_cart.png` - For Shopping Cart
- `checkout.png` - For Checkout
- `orders.png` - For Orders
- `authentication.png` - For Authentication
- `my_account.png` - For My Account
- `search.png` - For Search
- `wishlist.png` - For Wishlist
- `shipping_address.png` - For Shipping & Address

## How to Add Screenshots

1. Take a screenshot of the screen you want to display
2. Save it in this directory with the appropriate name
3. Update the `PageInfo` in `lib/data/api_data.dart` to include the screenshot path:
   ```dart
   PageInfo(
     name: 'Splash Screen',
     screenshot: 'assets/screenshots/splash_screen.png',
     apis: [...],
   ),
   ```

The screenshot will automatically display in the dashboard when you select that page.




