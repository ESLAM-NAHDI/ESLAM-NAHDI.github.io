import '../models/api_info.dart';

class ApiData {
  static List<PageInfo> getPages() {
    return [
      // Splash Screen
      PageInfo(
        name: 'Splash Screen',
        screenshot: 'assets/screenshots/splash.png',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-error-page',
            description: 'Fetches error page content',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-error-page?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-system-settings',
            description: 'Fetches system settings',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-system-settings?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-splash-content',
            description: 'Fetches splash screen content',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-splash-content?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-onboarding-content',
            description: 'Fetches onboarding content',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-onboarding-content?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
        ],
      ),

      // Onboarding Screen
      PageInfo(
        name: 'Onboarding Screen',
        screenshot: 'assets/screenshots/onboarding.png',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-onboarding-content',
            description: 'Fetches onboarding content (carousel/slides)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-onboarding-content?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
        ],
      ),

      // Login Screen
      PageInfo(
        name: 'Login Screen',
        screenshot: 'assets/screenshots/login.png',
        apis: [
          ApiInfo(
            url: 'api/v1/users/login-with-otp',
            body: '{"username":"+966592667414","country_id":"SA"}',
            description: 'Step 1: Initiates login with OTP (sends OTP to phone)',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/login-with-otp" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"username":"+966592667414","country_id":"SA"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/login-with-otp/verify?ecom=true',
            body: '{"tx_id":"<tx_id_from_step1>","otp":"123456"}',
            description: 'Step 2: Verifies OTP and completes login (requires tx_id from step 1)',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/login-with-otp/verify?ecom=true" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"tx_id":"<tx_id_from_login-with-otp>","otp":"123456"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/login?ecom=true',
            body: '{"username":"+966592667414","password":"Judy@293789650","country_id":"SA"}',
            description: 'Logs in user with phone and password',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/login?ecom=true" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"username":"+966592667414","password":"Judy@293789650","country_id":"SA"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/customer/mini-profile',
            description: 'Retrieves mini profile information',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/customer/mini-profile?member_id=804400011&locale=en-SA&device=app" -H "Authorization: Bearer <access_token>" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
        ],
      ),

      // Register Screen
      PageInfo(
        name: 'Register Screen',
        screenshot: 'assets/screenshots/register.png',
        apis: [
          ApiInfo(
            url: 'api/v1/users/register',
            body: '{"username":"+966592667414","country_id":"SA"}',
            description: 'Step 1: Initiates registration (sends OTP to new user)',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/register" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"username":"+966592667414","country_id":"SA"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/register/resend-otp',
            body: '{"tx_id":"<tx_id>"}',
            description: 'Resends OTP for registration',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/register/resend-otp" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"tx_id":"<tx_id>"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/register/verify?ecom=true',
            body: '{"tx_id":"<tx_id>","otp":"123456","password":"NewPass123!"}',
            description: 'Step 2: Verifies OTP and sets password to complete registration',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/register/verify?ecom=true" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"tx_id":"<tx_id>","otp":"123456","password":"NewPass123!"}\' -L -k',
          ),
        ],
      ),

      // Forgot Password Screen
      PageInfo(
        name: 'Forgot Password Screen',
        screenshot: 'assets/screenshots/forget-password.png',
        apis: [
          ApiInfo(
            url: 'api/v1/users/forgot-password',
            body: '{"username":"+966592667414","country_id":"SA"}',
            description: 'Step 1: Initiates password reset (sends OTP)',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/forgot-password" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"username":"+966592667414","country_id":"SA"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/forgot-password/verify',
            body: '{"tx_id":"<tx_id>","otp":"123456"}',
            description: 'Step 2: Verifies OTP for password reset',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/forgot-password/verify" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"tx_id":"<tx_id>","otp":"123456"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/users/forgot-password/set-new-password',
            body: '{"tx_id":"<tx_id>","otp":"123456","new_password":"NewPass123!"}',
            description: 'Step 3: Sets new password after OTP verification',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://sso.nahdionline.com/api/v1/users/forgot-password/set-new-password" -H "accept: application/json" -H "content-type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -d \'{"tx_id":"<tx_id>","otp":"123456","new_password":"NewPass123!"}\' -L -k',
          ),
        ],
      ),

      // Home Page
      PageInfo(
        name: 'Home Page',
        screenshot: 'assets/screenshots/home_screen.png',
        apis: [
          ApiInfo(
            url: 'api/v1/address/list',
            description: 'Retrieves user shipping addresses list',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/address/list?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDA4MjA2LCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDA0NjA2LCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.Vjc1aPdpBh5ndmsN5rTWzpTcbycYOZGLSx8Ccmo0_J4DhB7uRR28OBM-xOhjKE7LPyjSJFgBI-okyghrBYZSq2viG1Pga4u-LwZSfpPKtiZVeyUyfYl5X3g7b9vY_JMUf3xTJsswEhoPdZHIGIlcr0siSHhgREa56Kxo5mwS2BRh_MjI-wjuQLcjn9bdiKC6OVdptMd9UJNdPkuQsorZZ9tTqGbOgdfa5Gd7XciusWYV5sHNYZSHgjf7xBpafMRVBTvaYM8ZHkp53C9wWMBvLy3gylwCrmqHrMiZXYzWnUegdAsfvEU5LvzVy1ckSqxIX0EjuQbMe7If-9xxvxsSyg" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDA0NjA3LCJleHAiOjE3NjMwMDgyMDd9.jJYWIrHLONQUQtTGJV2nS5P3ilqeONwvrogPujNauwA" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/nuhdeek/profile',
            description: 'Retrieves Nuhdeek profile (v1)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/nuhdeek/profile?nuhdeek_id=804400011&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v2/nuhdeek/profile',
            description: 'Retrieves Nuhdeek profile with family points balance (used for app bar points badge)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v2/nuhdeek/profile?nuhdeek_id=804400011&locale=en-SA&device=app&fields=familyPoints,segments,cashBalanceAndExpiring" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/mini-basket',
            description: 'Post-login: Retrieves mini basket (cart icon badge) – called when Home tab opens',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/mini-basket?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/nuhdeek/validate-family',
            body: '{"mobile_number":"+966592667414"}',
            description: 'Validates family member for Nuhdeek program',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://b12.nahdionline.com/api/v1/nuhdeek/validate-family?locale=en-SA&device=app" -H "content-type: application/json" -H "accept: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDA4MjA2LCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDA0NjA2LCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.Vjc1aPdpBh5ndmsN5rTWzpTcbycYOZGLSx8Ccmo0_J4DhB7uRR28OBM-xOhjKE7LPyjSJFgBI-okyghrBYZSq2viG1Pga4u-LwZSfpPKtiZVeyUyfYl5X3g7b9vY_JMUf3xTJsswEhoPdZHIGIlcr0siSHhgREa56Kxo5mwS2BRh_MjI-wjuQLcjn9bdiKC6OVdptMd9UJNdPkuQsorZZ9tTqGbOgdfa5Gd7XciusWYV5sHNYZSHgjf7xBpafMRVBTvaYM8ZHkp53C9wWMBvLy3gylwCrmqHrMiZXYzWnUegdAsfvEU5LvzVy1ckSqxIX0EjuQbMe7If-9xxvxsSyg" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDA0NjA3LCJleHAiOjE3NjMwMDgyMDd9.jJYWIrHLONQUQtTGJV2nS5P3ilqeONwvrogPujNauwA" -d \'{"mobile_number":"+966592667414"}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-homepage-content',
            description: 'Fetches homepage content including banners, categories, and featured products',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-homepage-content?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/personalization/experience',
            body: '{"user":{"dyid":"","dyid_server":null,"active_consent_accepted":true,"sharedDevice":false},"session":{"dy":null},"selector":{"names":["Hook&Hold"]},"context":{"page":{"type":"HOMEPAGE","data":[],"location":"Home Page","referrer":"","locale":"en_SA"},"device":{"type":"SMARTPHONE"},"channel":"APP"},"options":{"is_implicit_pageview":true}}',
            description: 'Fetches personalized experience data',
            numberOfCalls: 6,
            method: 'POST',
            curl: 'curl -X POST "https://b12.nahdionline.com/api/v1/personalization/experience?zone_id=536%3A1002%2C1107%3A66661%2C1118%3A66667%2C1005%3A10370%2C1006%3A10371%2C621%3A101444%2C622%3A10555%2C819%3A101650%2C820%3A101372%2C619%3A101747%2C620%3A101777%2C1135%3A10360&available_only=false&locale=en-SA&device=app" -H "content-type: application/json" -H "accept: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDA4MjA2LCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDA0NjA2LCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.Vjc1aPdpBh5ndmsN5rTWzpTcbycYOZGLSx8Ccmo0_J4DhB7uRR28OBM-xOhjKE7LPyjSJFgBI-okyghrBYZSq2viG1Pga4u-LwZSfpPKtiZVeyUyfYl5X3g7b9vY_JMUf3xTJsswEhoPdZHIGIlcr0siSHhgREa56Kxo5mwS2BRh_MjI-wjuQLcjn9bdiKC6OVdptMd9UJNdPkuQsorZZ9tTqGbOgdfa5Gd7XciusWYV5sHNYZSHgjf7xBpafMRVBTvaYM8ZHkp53C9wWMBvLy3gylwCrmqHrMiZXYzWnUegdAsfvEU5LvzVy1ckSqxIX0EjuQbMe7If-9xxvxsSyg" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDA0NjA3LCJleHAiOjE3NjMwMDgyMDd9.jJYWIrHLONQUQtTGJV2nS5P3ilqeONwvrogPujNauwA" -d \'{"user":{"dyid":"","dyid_server":null,"active_consent_accepted":true,"sharedDevice":false},"session":{"dy":null},"selector":{"names":["Hook&Hold"]},"context":{"page":{"type":"HOMEPAGE","data":[],"location":"Home Page","referrer":"","locale":"en_SA"},"device":{"type":"SMARTPHONE"},"channel":"APP"},"options":{"is_implicit_pageview":true}}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/wishlist/items',
            description: 'Retrieves all items in user wishlist',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/wishlist/items?is_detailed=true&page=1&size=10000&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDA4MjA2LCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDA0NjA2LCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.Vjc1aPdpBh5ndmsN5rTWzpTcbycYOZGLSx8Ccmo0_J4DhB7uRR28OBM-xOhjKE7LPyjSJFgBI-okyghrBYZSq2viG1Pga4u-LwZSfpPKtiZVeyUyfYl5X3g7b9vY_JMUf3xTJsswEhoPdZHIGIlcr0siSHhgREa56Kxo5mwS2BRh_MjI-wjuQLcjn9bdiKC6OVdptMd9UJNdPkuQsorZZ9tTqGbOgdfa5Gd7XciusWYV5sHNYZSHgjf7xBpafMRVBTvaYM8ZHkp53C9wWMBvLy3gylwCrmqHrMiZXYzWnUegdAsfvEU5LvzVy1ckSqxIX0EjuQbMe7If-9xxvxsSyg" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDA0NjA3LCJleHAiOjE3NjMwMDgyMDd9.jJYWIrHLONQUQtTGJV2nS5P3ilqeONwvrogPujNauwA" -L -k',
          ),
          ApiInfo(
            url: 'data/statistics.json',
            description: 'Bazaarvoice: Fetches product ratings/stats for product carousels (star ratings). Base: api.bazaarvoice.com. Requires Passkey & ApiVersion=5.4.',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://api.bazaarvoice.com/data/statistics.json?filter=ProductId:SKU1,SKU2&stats=Reviews&Passkey=<passkey>&ApiVersion=5.4" -H "accept: application/json" -H "content-type: application/json" -L -k',
          ),
          ApiInfo(
            url: 'data/reviews.json',
            description: 'Bazaarvoice: Fetches product reviews. Base: api.bazaarvoice.com. Requires Passkey & ApiVersion=5.4.',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://api.bazaarvoice.com/data/reviews.json?Filter=ProductId:SKU1,SKU2&Include=Products&Stats=Reviews&Offset=0&Passkey=<passkey>&ApiVersion=5.4" -H "accept: application/json" -H "content-type: application/json" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/game/fetch-scratch-to-win',
            description: 'Fetches scratch card game data for gamification',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/game/fetch-open-gift-box',
            description: 'Fetches open gift box game data',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/game/fetch-spin-the-wheel',
            description: 'Fetches spin the wheel game data',
            numberOfCalls: 1,
            method: 'GET',
          ),
        ],
      ),

      // Product Detail (PDP)
      PageInfo(
        name: 'Product Detail (PDP)',
        screenshot: 'assets/screenshots/product-detail.png',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-pdp-content',
            description: '1. PDP Content - Fetches PDP structure, modules, and template by SKU',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-pdp-content?sku_id=<sku>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/products',
            description: '2. Product Data - Fetches product details by SKU(s)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/products?skus=<sku>&is_bundled=false&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/products/availability',
            description: '3. Availability - Fetches product availability by SKU and zone',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/products/availability?skus=<sku>&zone_id=<zone_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/products/tile',
            description: '4. Tile Availability - Fetches tile/listing availability',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/products/tile?skus=<sku>&zone_id=<zone_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -L -k',
          ),
          ApiInfo(
            url: 'data/statistics.json',
            description: '5. Bazaarvoice - Fetches product ratings/stats (star ratings)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://api.bazaarvoice.com/data/statistics.json?filter=ProductId:<sku>&stats=Reviews&Passkey=<passkey>&ApiVersion=5.4" -H "accept: application/json" -H "content-type: application/json" -L -k',
          ),
          ApiInfo(
            url: 'data/reviews.json',
            description: '6. Bazaarvoice - Fetches product reviews (paginated)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://api.bazaarvoice.com/data/reviews.json?Filter=ProductId:<sku>&Include=Products&Stats=Reviews&Offset=0&Limit=10&Passkey=<passkey>&ApiVersion=5.4" -H "accept: application/json" -H "content-type: application/json" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/personalization/experience',
            description: '7. Dynamic Yield - Personalized experience (social proof, recommendations)',
            numberOfCalls: 1,
            method: 'POST',
            curl: 'curl -X POST "https://b12.nahdionline.com/api/v1/personalization/experience?zone_id=<zone_id>&available_only=false&locale=en-SA&device=app" -H "content-type: application/json" -H "accept: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -d \'{"selectors":["dySocialProof"],"pageType":"product","data":["<sku>"]}\' -L -k',
          ),
          ApiInfo(
            url: 'api/v1/gtm/items',
            description: '8. GTM - Item metadata for analytics (product view events)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/gtm/items?skus=<sku>" -H "accept: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/distance-message',
            description: '9. Distance Message - Fetches distance-related messages (when adding to cart)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/distance-message?skuList=<sku>&id=<basket_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/wishlist/items',
            description: '10. Wishlist - Check/add to wishlist from PDP',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/wishlist/items?is_detailed=true&page=1&size=10000&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
        ],
      ),

      // Shopping Cart
      PageInfo(
        name: 'Cart',
        screenshot: 'assets/screenshots/cart.png',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-cart-page',
            description: '1. Fetch cart page - Fetches cart page content and configuration',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-cart-page?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/shipping-fee-rules',
            description: '2. Shipping Fee Rules - Retrieves shipping fee calculation rules',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/shipping-fee-rules?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/basket',
            description: '3. Basket - Retrieves full cart/basket details with shipments',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/basket?id=<basket_id>&zone_id=<zone_id>&is_detailed=true&shipments=true&checkout=false&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/personalization/experience',
            description: '4. Items - Dynamic Yield personalized product items/recommendations',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/customer/mini-profile',
            description: '5. Profile - Retrieves customer profile for cart display',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/customer/mini-profile?member_id=<nuhdeek_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/gift-items',
            description: '6. Gift Items - Retrieves available gift items for the cart',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/gift-items?id=<basket_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/distance-message',
            description: '7. Distance Message - Fetches distance-related messages for cart',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/distance-message?skuList=<skus>&id=<basket_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/personalization/experience',
            description: '8. Express (Experience) - Dynamic Yield personalized experience',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'https://api.bazaarvoice.com/data/statistics.json',
            description: '9. Bazaar Voice - Product ratings for cart items',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://api.bazaarvoice.com/data/statistics.json?filter=ProductId:SKU1,SKU2&stats=Reviews&Passkey=<passkey>&ApiVersion=5.4" -H "accept: application/json" -H "content-type: application/json" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/basket',
            description: '10. Basket - Retrieved again (full cart details)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/basket?id=<basket_id>&zone_id=<zone_id>&is_detailed=true&shipments=true&checkout=false&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
        ],
      ),

      // Checkout
      PageInfo(
        name: 'Checkout',
        screenshot: 'assets/screenshots/checkout.png',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-checkout-content',
            description: 'Fetches checkout page content and configuration',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-checkout-content?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/customer/mini-profile',
            description: 'Profile - Mini profile (customer info for checkout)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/customer/mini-profile?member_id=<nuhdeek_id>&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/gtm/items',
            description: 'Items - GTM product items (analytics)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/gtm/items?skus=<comma_separated_skus>" -H "accept: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/checkout/apply-cash-wallet',
            description: 'Apply Cash Wallet - Use wallet balance at checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/remove-cash-wallet',
            description: 'Remove applied Cash Wallet from checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/cart/basket',
            description: 'Basket with checkout=true (cart for checkout screen)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/basket?id=<basket_id>&zone_id=<zone_id>&is_detailed=true&shipments=true&checkout=true&locale=en-SA&device=app" -H "accept: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/address/list',
            description: 'Fetch user addresses for Deliver to section',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/address/default-shipping',
            description: 'Get or set default shipping address',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v2/store/time-slots',
            description: 'Available time slots for Select delivery slot',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v2/store/time-slots?zone_id=<zone_id>&locale=en-SA&device=app" -H "accept: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/checkout/payment-methods',
            description: 'Retrieves available payment methods',
            numberOfCalls: 2,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/checkout/payment-methods?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/coupons',
            body: '{"coupon_code": "PROMO123"}',
            description: 'Apply coupon code (Enter coupon code here)',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/gift-card/apply-gift-card',
            body: '{"gift_card_code": "..."}',
            description: 'Apply gift card/voucher at checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/gift-card/remove-gift-card',
            description: 'Remove applied gift card',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/gift-card/points',
            description: 'Get gift card points',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/qitaf/available',
            description: 'Qitaf available points for redemption',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/qitaf/redemption-qitaf-pts',
            body: '{"points": 100, "otp": "..."}',
            description: 'Redeem Qitaf points at checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/payment-sessions',
            description: 'Payment Session - Create payment session for gateway',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/payment-sessions/{id}/submit',
            description: 'Payment Session Submit - Submit payment session',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/apply-cash-wallet',
            description: 'Apply Cash Wallet - Apply Nuhdeek cash wallet at checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/remove-cash-wallet',
            description: 'Remove applied cash wallet from checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/cko/stcpay',
            description: 'STC Pay payment initiation',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/nuhdeek-balance',
            description: 'Retrieves Nuhdeek balance for checkout (apply points)',
            numberOfCalls: 2,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/checkout/nuhdeek-balance?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "X-ID-Token: Bearer <id_token>" -H "Authorization: Bearer <access_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/checkout/apply-nuhdeek-points',
            body: '{"points": 100}',
            description: 'Applies Nuhdeek points to checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/remove-nuhdeek-points',
            description: 'Removes applied Nuhdeek points from checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/checkout/apply-payment-method',
            body: '{"payment_method": "credit_card", "payment_data": {...}}',
            description: 'Applies selected payment method to checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/order/create',
            body: '{"basket_id": "basket_id", "shipping_address": {...}, "payment_method": {...}}',
            description: 'Creates a new order from checkout',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/order/fail',
            body: '{"order_id": "order_id", "reason": "payment_failed"}',
            description: 'Marks an order as failed',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/cart/distance-message',
            description: 'Retrieves distance message for cart items',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/distance-message?skuList=100015980%2C102763658%2C102763666%2C103243857%2C102867941&id=drKFkgUwUu6awcdetFbz0FMxMvDoLN4j&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cart/gift-items',
            description: 'Retrieves available gift items for checkout',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cart/gift-items?id=drKFkgUwUu6awcdetFbz0FMxMvDoLN4j&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
          ApiInfo(
            url: 'api/v2/store/time-slots',
            description: 'Retrieves available time slots for delivery',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v2/store/time-slots?zone_id=536%3A1002%2C1005%3A10370%2C1107%3A66661%2C1118%3A66667%2C1006%3A10371%2C621%3A101444%2C622%3A10555%2C819%3A101650%2C820%3A101372%2C619%3A101747%2C620%3A101777%2C1135%3A10360&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/boosted-points/saved-amount',
            description: 'Retrieves saved amount from boosted points',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/boosted-points/saved-amount?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/boosted-points/available-points',
            description: 'Retrieves available boosted points',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/boosted-points/available-points?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "X-ID-Token: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJCaXJ0aCBEYXRlIjoiMjAwMi0xMS0wMSIsIkNvbnNlbnQgUHJpbWUiOnRydWUsIkNvbnNlbnQgUHJvbW8iOnRydWUsIkdlbmRlciI6Im1hbGUiLCJJbnN1cmFuY2UgUHJvdmlkZXIiOiJCdXBhIiwiTGFuZ3VhZ2UiOiJlbiIsIlByb2dyYW0iOiJOdWhkZWVrIiwiU291cmNlIjoid2ViIiwiU3RvcmUiOiJTQSIsImF1ZCI6WyIyYzczNW0wcTlhMmhrcW9mbXJjZGozamNoZiJdLCJkZXZpY2VJRCI6InxGRTozMjpDRTpERTpCQzo0MDpDRjo2RDo2OTpBRjo3MzpBMTpDRTo5NjpCRTo3NDpEQTpDNToxNTozOTo5NjpEMTpCRjo5Mjo2NzpCNTo5MTpFRDpFNTpDRjowOTo5Qnw0ODY4MDFCNS0xRkI0LTQ5NDYtQjhERC1FQjk1NkZCQTY3M0J8ODgyOURENTctMEYwRi00RDQ5LUIyREUtOTg2RjNBNkFEOTgyfDY5YTYzY2JjM2NjOWYyODN8QkQzRDJBMTItMzZFMS00MTk0LTgzMzctNjBEMkExOUEwQkI3fDBEMzY0RjY0LTU4NTctNEQ1OS04N0U5LTIzNzAzM0UyODU5OHwzMDM0RTRGRi05RkY3LTQwNjMtQTVGNi0yM0RDNjREOEZBRDQiLCJlbWFpbCI6ImlzbWFlZWwubWFAbmFoZGkuc2EiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZXhwIjoxNzYzMDE1ODQwLCJmaXJzdG5hbWUiOiJNYWhtb3VkZGRkIiwiaWF0IjoxNzYzMDEyMjQwLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLm1lLXNvdXRoLTEuYW1hem9uYXdzLmNvbS9tZS1zb3V0aC0xX0FWWTFnZElkNyIsImxhc3RuYW1lIjoiSXNtYWVhbCIsInBob25lIjoiKzk2NjU5MjY2NzQxNCIsInBob25lX3ZlcmlmaWVkIjp0cnVlLCJwcm9ncmFtSUQiOiJOdWhkZWVrIiwic3RvcmVJRCI6IlNBIiwic3ViIjoiZDFhMDQ1NTAtNTA0MS03MGNiLTFkZjAtNTUyZjY3OGJhYjlhIiwidXNlcm5hbWUiOiI4MDQ0MDAwMTEifQ.ArgPmoDbUbIVgHS445FIBpD2vZfo-anfPH9JDSk2af12Q_G8y53Yg0lj7F_qE3AeZ4WQljfLchUjK5rAUMad7h3pyC3KUoVi2z9yIbsrgSFJvZg2NC9DlqtrzvvY-PtRx31GW-jv3zaYWwUNmI7_ZER-2PbQ9vydjEvdS8rGwP1JECQYdsS0Hs-k3nl3Hf9mm3AHWhaUq5XnB0IqklNyJJ_Dep-2Wxpx6tLcVv0PLSk28PsvSsXWBkyAL3xGD3UPUJ-BOHM5FVU8_SpWeVs0jDcRniU5H0D9vrmSOe8k2Qo72_J0tDD9DYRo6X6WXzcv5POCg_CXIkUFqNu4iof5dA" -H "Authorization: eyJraWQiOiIxIiwiYWxnIjoiSFMyNTYifQ.eyJ1aWQiOjIzMzc2MTEsInV0eXBpZCI6MywiaWF0IjoxNzYzMDEyMjQwLCJleHAiOjE3NjMwMTU4NDB9.tCCLpNn7L9C04fxsV9lKc2M2HFkvt4veJH3aTB24fbQ" -L -k',
          ),
        ],
      ),

      // Orders
      PageInfo(
        name: 'Orders',
        apis: [
          ApiInfo(
            url: 'api/v1/order/list',
            description: 'Retrieves list of user orders',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/order/{orderNumber}/details',
            description: 'Fetches detailed information about a specific order',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/order/fulfilment/{orderNumber}/status',
            description: 'Gets order fulfilment status',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/order/list/offline',
            description: 'Retrieves offline orders list',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/erx/order-history',
            description: 'Fetches eRx (electronic prescription) order history',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/erx/order/{orderNumber}',
            description: 'Gets specific eRx order details',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'nahdi/pharmacy/getERXForMobile',
            description: 'Fetches eRx details for mobile',
            numberOfCalls: 1,
            method: 'GET',
          ),
        ],
      ),

      // My Account (More tab) - only 2 APIs called on screen open
      PageInfo(
        name: 'My Account',
        screenshot: 'assets/screenshots/account-page.png',
        apis: [
          ApiInfo(
            url: 'api/v1/customer/mini-profile',
            description: 'Retrieves customer profile (user info, Nuhdeek ID)',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/customer/mini-profile?member_id=804400011&locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-account-page',
            description: 'Fetches my account page content and menu structure',
            numberOfCalls: 1,
            method: 'GET',
            curl: 'curl -X GET "https://b12.nahdionline.com/api/v1/cms/fetch-account-page?locale=en-SA&device=app" -H "accept: application/json" -H "Content-Type: application/json" -H "Accept-Encoding: gzip,deflate" -H "client_id: dddc5530-fbc5-4a30-bf63-3d3d7f63de6b" -H "is_debug: true" -H "Authorization: Bearer <access_token>" -H "X-ID-Token: Bearer <id_token>" -L -k',
          ),
        ],
      ),

      // Search
      PageInfo(
        name: 'Search',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-no-search-results',
            description: 'Fetches content for no search results page',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/cms/fetch-landing-page',
            description: 'Fetches product listing page content for search results',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/barcodes/search?query={barcode}',
            description: 'Searches for products by barcode',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/category/{id}/children',
            description: 'Fetches child categories for a given category',
            numberOfCalls: 1,
            method: 'GET',
          ),
        ],
      ),

      // Wishlist
      PageInfo(
        name: 'Wishlist',
        apis: [
          ApiInfo(
            url: 'api/v1/cms/fetch-wishlist-content',
            description: 'Fetches wishlist page content',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/wishlist/items',
            description: 'Retrieves all items in user wishlist',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/wishlist',
            body: '{"sku": "SKU123", "action": "add"}',
            description: 'Adds or removes item from wishlist',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/wishlist/remove-item',
            body: '{"sku": "SKU123"}',
            description: 'Removes specific item from wishlist',
            numberOfCalls: 1,
            method: 'POST',
          ),
        ],
      ),

      // Shipping & Address
      PageInfo(
        name: 'Shipping & Address',
        apis: [
          ApiInfo(
            url: 'api/v1/shipping/addresses',
            description: 'Retrieves user shipping addresses',
            numberOfCalls: 1,
            method: 'GET',
          ),
          ApiInfo(
            url: 'api/v1/shipping/addresses',
            body: '{"address": {...}, "type": "home"}',
            description: 'Creates a new shipping address',
            numberOfCalls: 1,
            method: 'POST',
          ),
          ApiInfo(
            url: 'api/v1/shipping/addresses/{id}',
            body: '{"address": {...}}',
            description: 'Updates an existing shipping address',
            numberOfCalls: 1,
            method: 'PUT',
          ),
          ApiInfo(
            url: 'api/v1/shipping/addresses/{id}',
            description: 'Deletes a shipping address',
            numberOfCalls: 1,
            method: 'DELETE',
          ),
          ApiInfo(
            url: 'api/v1/customers/{customerId}',
            description: 'Fetches customer information',
            numberOfCalls: 1,
            method: 'GET',
          ),
        ],
      ),
    ];
  }
}
