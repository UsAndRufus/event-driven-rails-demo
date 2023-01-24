# Event-Driven Rails demo
This is a demo for the talk I delivered at Geekle Ruby on Rails Global Summit 2023

## Installation
1. Clone repo
2. Run `bundle install`
3. Run `rails db:migrate && rails db:seed`

## Usage
You can switch users in the top-right. 
Authors can write articles and see all drafts. 
Readers just see published articles.

You can view all events at the `/res` endpoint.

## References
- [Rails Event Store gem](https://railseventstore.org/)
- [RES Ecommerce example app](https://github.com/RailsEventStore/ecommerce)
- [Martin Fowler on Domain Driven Design](https://martinfowler.com/tags/domain%20driven%20design.html)
- [Domain Driven Rails by Robert Pankowecki & Arkency Team](https://rubyandrails.info/books/domain-driven-rails)
- [Domain Driven Design by Eric Evans](https://books.google.co.uk/books/about/Domain_driven_Design.html?id=7dlaMs0SECsC&redir_esc=y)
