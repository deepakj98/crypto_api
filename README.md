# README

# Crypto Price Tracker

A Ruby on Rails application that fetches and caches cryptocurrency prices using a background job.

## Features

- Fetch crypto prices from CoinGecko API
- Background job runs every minute (Solid Queue)
- Caching using Rails cache
- Fallback mechanism:
  - API → Cache → DB
- Supports dynamic user search (`/prices/:symbol`)
- HTML + JSON responses
- RSpec test coverage (Job, Fallback, Cache)

---

## Tech Stack

- Ruby on Rails
- SQLite (default)
- Solid Queue (background jobs)
- HTTParty (API calls)
- RSpec (testing)

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/deepakj98/crypto_api.git
cd crypto_api
```

### 2. Install dependencies
```bash
	bundle install
````

### 3. Setup db
```bash
	rails db:create
	rails db:migrate
```

### 4. start server
```bash
	rails server
```

### 5. start job
```bash
	bin/jobs start
```
