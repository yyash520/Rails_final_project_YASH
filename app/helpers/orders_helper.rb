module OrdersHelper
  def status_badge_class(status)
    case status.to_s
    when "pending"
      "bg-warning text-dark"
    when "completed"
      "bg-success"
    when "cancelled"
      "bg-danger"
    else
      "bg-secondary"
    end
  end
end
