class PagesController < ApplicationController
  def about
    # You can add any instance variables needed for the about page
    @team_members = [
      { name: "Yash", role: "Founder" },
      { name: "Maple", role: "Mascot" }
    ]
  end

    def about
      @page = Page.find_by(slug: 'about') || default_about_content
    end

    def contact
      @page = Page.find_by(slug: 'contact') || default_contact_content
    end

    private

    def default_about_content
      OpenStruct.new(
        title: 'About Us',
        content: '<h2>Our Story</h2><p>Maple Reads was founded in 2023...</p>'
      )
    end

    def default_contact_content
      OpenStruct.new(
        title: 'Contact Us',
        content: '<h2>Get in Touch</h2><p>Email us at...</p>'
      )
    end
  end