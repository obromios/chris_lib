# encoding: utf-8
require 'spec_helper'
describe ChrisLib  do
	describe 'Date extensions' do
		describe "US formatters" do
			let(:date){Date.new(2014,9,8)}
			it "should provide US format" do
				expect(date.us_format).to eq 'September 8, 2014'
			end
			it "should provide US format with week day" do
				expect(date.us_format_with_weekday).to eq 'Monday, September 8, 2014'
			end
		end 
		describe 'short_format' do
			let(:date){Date.new(2014,9,8)}
			it{ expect(date.short_format).to eq 'Sep 8, 2014' }
		end
		describe "charmians_format" do
			it "should provide date the way charmian likes it" do
			  date=Date.new(2014,4,1)
				expect(date.charmians_format).to eq 'Tuesday, 1st April, 2014'
			end
			it "should work for 22nd" do
				date=Date.new(2014,4,22)
				expect(date.charmians_format).to include '22nd April, 2014'
			end
			it "should work for 23rd" do
				date=Date.new(2014,4,23)
				expect(date.charmians_format).to include '23rd April, 2014'
			end
			it "should work for others" do
				date=Date.new(2014,4,11)
				expect(date.charmians_format).to include '11th April, 2014'
			end
			it "should work for 31st" do
				date=Date.new(2014,8,31)
				expect(date.charmians_format).to include '31st August, 2014'
			end
			describe :charmians_format_sup do
				it "should reject non date objects" do
					expect {'stringy'.charmians_format_sup}.to raise_error NoMethodError
				end
				it "should provide html superscript if requested" do
					date=Date.new(2014,4,1)
					expect(date.charmians_format_sup).to include '1<sup>st</sup> April, 2014'
				end
			end
		end
	end
end
