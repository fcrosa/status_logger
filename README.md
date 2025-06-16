# Service Installation Guide

## Overview
The objective of the Status Logger Service is to provide a centralized and extensible mechanism for recording user status changes and related data during security checks.
This guide explains how to set up and run the Status Logger Service built with Ruby on Rails. The service uses PostgreSQL for data persistence, Redis for caching, and integrates with the VPNAPI for VPN and proxy detection.

---

## Prerequisites

### 1. System Requirements

* **Operating System**: Linux, macOS, or Windows with WSL2.
* **Ruby**: Version 3.2 or higher.
* **Rails**: Version 7.x (API-only mode).
* **PostgreSQL**: Version 12 or higher.
* **Redis**: Version 6.x or higher.

### 2. Dependencies

* Bundler: `gem install bundler`
* VPNAPI Key: Obtain from [VPNAPI](https://vpnapi.io).
---

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/fcrosa/status_logger.git
cd status_logger
```

### 2. Install Dependencies

Install required Ruby gems:

```bash
bundle install
```

### 3. Configure the Environment

Create the`.env`file into the root directory (it's not included), with the following keys:

```dotenv
PG_TEST_USER="your_username"
PG_TEST_PWD="your_password"
REDIS_URL=redis://localhost:6379/0
VPNAPI_KEY=your_vpnapi_key
```

### 4. Set Up the Database

Create and migrate the database:

```bash
rails db:create db:migrate
```

### 5. Start the Services

Run the following services:

* PostgreSQL
* Redis

Start the Rails server:

```bash
rails server
```

### 6. Load Whitelist Countries into Redis

To load the country whitelist into Redis, run the following Rake task:
```bash
rails redis:load_country_whitelist
```
You can find the ```country_whitelist.txt``` in: ```/config/support_files/country_whitelist.txt```

---

## Testing the Setup

### 1. API Endpoint

Test the `/api/v1/user/check_status` endpoint using cURL or a tool like Postman:

**Example Request:**

```bash
curl -X POST http://localhost:3000/api/v1/user/check_status \
-H "Content-Type: application/json" \
-H "CF-IPCountry: US" \
-d '{
  "idfa": "8264148c-be95-4b2b-b260-6ee98dd53P45",
  "rooted_device": false
}'
```

**Expected Response:**

```json
{
  "ban_status": "not_banned"
}
```
**I recommend using Postman to test different scenarios and test all possible combinations.**

### 2. Run Tests

- Added 100% test coverage for `/controllers` and `/services` using RSPEC unit tests.
- Added support for `pry` and being able to debug using `binding.pry`


You can Run RSpec tests locally:

```bash
bundle exec rspec
```


---

## Troubleshooting

### Common Issues

1. **Database Connection Error**

   * Ensure PostgreSQL is running and the credentials in `.env` are correct.

2. **Redis Not Connecting**

   * Verify Redis is running on the correct port.

3. **VPNAPI Error**

   * Verify your VPNAPI key is valid and that your environment file is configured properly.

### Logs

Check logs for detailed error messages:

```bash
tail -f log/development.log
```

---

## Additional Notes

### Future Enhancements

* Integrate with external logging services.
* Extend caching to include more endpoints.

For more information, refer to the [documentation](https://github.com/yourusername/your-repo/wiki).

---

## Support

If you encounter any issues, please contact support at `crosafernando@gmail.com` or open an issue on GitHub.
