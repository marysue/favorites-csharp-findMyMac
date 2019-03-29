require_relative "../config/environment"

macs_array = Scraper::scrape_refurbished_macs

finder = Finder::findMyMac.newer

#control handed off to findMyMac
finder.findMacs(macs_array)
