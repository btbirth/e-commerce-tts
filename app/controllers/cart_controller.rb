class CartController < ApplicationController
	before_filter :authenticate_user!, only: [:checkout]

  def add_to_cart
  	line_item = LineItem.new
  	line_item.product_id = params[:product_id]
  	line_item.quantity = params[:quantity]
  	line_item.save

  	line_item.line_item_total = line_item.product.price * line_item.quantity
  	line_item.save

  	redirect_to view_order_path
  end

  def view_order
  	@line_items = LineItem.all
  end

  def checkout
  	@line_items = LineItem.all
  	@order = Order.new
  	@order.user = current_user

  	sum = 0

  	@line_items.each do |line_item|
  		if @order.order_items[line_item.product_id].nil?
	  		@order.order_items[line_item.product_id] = line_item.quantity
	  	else
	  		@order.order_items[line_item.product_id] += line_item.quantity
	  	end

  		sum += line_item.line_item_total
  	end

  	@order.subtotal = sum
  	@order.sales_tax = sum * 0.08
  	@order.grand_total = sum + @order.sales_tax
  	@order.save

  	@line_items.each do |line_item|
  		line_item.product.quantity -= line_item.quantity
  		line_item.product.save
  	end

  	LineItem.destroy_all
  end
end
