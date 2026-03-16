# Club Project API Reference

This document helps you (and the AI) quickly find API calls for each screen in the **club project** (nahdi-mobile) so you can add them to this API dashboard.

## Project Location

```
/Users/eslamwaheedrafat/StudioProjects/nahdi-mobile
```

## Quick Lookup: Screen → API Files

| Screen/Feature | Endpoints | Datasource |
|----------------|-----------|------------|
| **Splash** | `lib/features/splash/data/endpoints/splash_url_endpoints.dart` | `lib/features/splash/data/datasource/splash_datasource_impl.dart` |
| **Mama Club** | `lib/features/mama_club/data/mama_club_endpoints.dart` | `lib/features/mama_club/data/mama_club_datasource.dart` |
| **Login / Auth** | `lib/features/auth/presentation/data/auth_endpoints.dart` | — |
| **Home** | `lib/features/main/home/data/endpoints/home_endpoints.dart` | — |
| **Cart** | `lib/features/cart/data/cart_endpoints.dart` | — |
| **Checkout** | `lib/features/checkout/data/checkout_endpoints.dart` | — |
| **Orders** | `lib/features/order/data/order_endpoints.dart` | — |
| **Wishlist** | `lib/features/my_wishlist/data/endpoints/wishlist_endpoints.dart` | — |
| **Address/Shipping** | `lib/features/shipping_method/data/endpoint/address_endpoint.dart` | — |
| **Onboarding** | `lib/features/onboarding_experience/data/endpoints/onboarding_url_endpoints.dart` | — |
| **System Settings** | `lib/features/main/home/data/endpoints/system_settings_endpoints.dart` | — |
| **My Account** | `lib/features/main/my_account/data/endpoints/my_account_endpoints.dart` | — |
| **Nuhdeek** | `lib/features/main/nuhdeek/data/endpoints/nudheek_endpoints.dart` | — |
| **Health** | `lib/features/health/data/health_endpoints.dart` | — |
| **ERx** | `lib/features/erx/data/erx_endpoints.dart` | — |

## Base URLs

- **Main API**: `https://b12.nahdionline.com/`
- **SSO (Auth)**: `https://sso.nahdionline.com/`

## How to Use

1. When you need APIs for a screen (e.g. splash, mama club), look up the row above.
2. Open the endpoints file in nahdi-mobile to see the API paths.
3. Open the datasource (if listed) to see request body and usage.
4. Add them to this dashboard in `lib/data/api_data.dart` as `ApiInfo` entries.

## Example: Splash Screen APIs (from club project)

From `splash_url_endpoints.dart`:
- `api/v1/cms/fetch-splash-content` (GET)

From `splash_datasource_impl.dart`: called via `networkService.get(SplashEndpoints.splashUrl)`.
