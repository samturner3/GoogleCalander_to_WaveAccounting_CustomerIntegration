# Google Calendar to Wave Accounting Customer Import

![](http://ansonalex.com/wp-content/uploads/2011/01/google-calendar-logo.png)
![](https://www.cloud-book.co.uk/wp-content/uploads/2013/09/Wave-Accounting.jpg)

## Breif

In my business, I accecpt bookings online via my website. These bookings are synced to a google calendar which contains all the appointment and customer details. 

I then had to manually enter this information into the accounting software to create invoices. 

I built this app to automate the process.

## Overview

The app uses the Google Calendar API to pull upcoming events using specific rules.
These events are then processed as the customer data is extracted. To do this I had to use various rules such as regular expressions to extract the email etc.

Once this data has been extracted it is put into a hash, then the multiple hashes are put into an array.

The results are then displayed to the user. The user then has an option to download the data in csv format that matches the accounting software format.

## Future

This app was developed as a stop-gap solution since the accounting software currentlly does not offer an API (It is in closed alpha stage). Once the API is open, I will change the app to import the customer data directly into the accounting software, and create an invoice for each customer.

## Installation

First clone the repo then
```
$ bundle install
$ rails db:create
$ rails db:migrate
$ rails s
```

## Authentication

The app will redirect you to a google login as it will ask for permission to access your google calendar. Once permission has been gained it will return with the valid token and use that for further communication.

