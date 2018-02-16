# Bandcamp Scraper App

To build this app I scraped through (parts) of [*Bandcamp*](www.bandcamp.com) and created a database of references to music that is shared under Creative Commons license.

The app allows users to filter Creative Commons music by genres (tags) and more specific license types. Before this app users had to user elaborate Google queries to look for music, which was a sub-optimal experience.

The app is live on [*Heroku*](https://creative-commons.herokuapp.com/). The database at Heroku free tier is limited to 10k rows, so this deployment option is mostly used for demonstration purposes. The entire database of albums is being built now and will be deployed on another service in the future.  