# == Schema Information
# Schema version: 20210125065024
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  last_login_at          :datetime
#  last_otp_used_at       :datetime
#  otp_secret             :text
#  password_digest        :text
#  unconfirmed_otp_secret :text
#  username               :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
