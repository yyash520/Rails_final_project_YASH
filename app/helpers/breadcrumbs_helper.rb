module BreadcrumbsHelper
  def render_breadcrumbs(crumbs)
    return if crumbs.blank?
    content_tag :nav, aria: { label: "breadcrumb" }, class: "breadcrumb-nav mb-3" do
      content_tag :ol, class: "breadcrumb" do
        crumbs.each_with_index.map do |(name, url), i|
          active = (i == crumbs.size - 1)
          content_tag :li, class: "breadcrumb-item#{' active' if active}", aria: (active ? { current: "page" } : {}) do
            active ? name : link_to(name, url)
          end
        end.join.html_safe
      end
    end
  end
end
