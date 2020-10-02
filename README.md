# Word Frequencies, N-Grams, and Word Correlations using Tidytext

This week's tutorial has 2 parts. For the first part, you will extend your web scraping to collect data from an entire website. Please reference the `rvest_example2.R` file for one such approach. Depending on the site you've chosen, you may need to use other strategies--like using RSelenium to scrape a full site. See the following tutorials for additional strategies:
- <http://thatdatatho.com/2019/01/22/tutorial-web-scraping-rselenium/>
- <http://joshuamccrain.com/tutorials/web_scraping_R_selenium.html>
As I mentioned in class, please be sure and follow web scraping best practices, and access the robots.txt file of your sites. If they do not list a preferred delay for your scraping activities (delay between each page visit), I suggest still using a delay of at least 3 seconds per page.

Goals:
- Scrape an entire complex site with multiple pages, or a longer list of simple static websites with similar content.

For the second part of the tutorial you'll be learning to analyze word frequencies, n-grams, and word correlations in your scraped data. In particular, the example R code I have produce in `freg-ngrams-corr.R` translates the examples from chapters 3 and 4 of *Text Mining with R* for data that has been scraped from the web.


Goals:
- Explore/compare raw word frequency, tf-idf word frequency, and tf-idf bigram frequency
- Visualize bigram relationships with a directed graph
- Explore word correlations across corpus
- Look at word correlations for particular words in your dataset
  - Compare for a single word, and for 4 different words
- Visualize correlation relationship in a cluster graph 
