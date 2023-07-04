require "test_helper"

class SettingsControllerTest < ActionController::TestCase
  context "when not logged in" do
    setup do
      @user = create(:user)
      get :edit
    end
    should redirect_to("the sign in page") { sign_in_path }
  end

  context "when logged in" do
    setup do
      @user = create(:user)
      sign_in_as(@user)
    end

    context "when user owns a gem with more than MFA_REQUIRED_THRESHOLD downloads" do
      setup do
        @rubygem = create(:rubygem)
        create(:ownership, rubygem: @rubygem, user: @user)
        GemDownload.increment(
          Rubygem::MFA_REQUIRED_THRESHOLD + 1,
          rubygem_id: @rubygem.id
        )
      end

      context "user has mfa disabled" do
        setup { get :edit }
        should "flash setup_required_html warning message" do
          assert_response :success
          assert page.has_content? "For protection of your account and your gems, you are required to set up multi-factor authentication."
        end
      end

      context "user has mfa set to weak level" do
        setup do
          @user.enable_totp!(ROTP::Base32.random_base32, :ui_only)
          get :edit
        end

        should "stay on edit settings page without redirecting" do
          assert_response :success
          assert page.has_content? "Edit settings"
        end
      end

      context "user has MFA set to strong level, expect normal behaviour" do
        setup do
          @user.enable_totp!(ROTP::Base32.random_base32, :ui_and_api)
          get :edit
        end

        should "stay on edit settings page without redirecting" do
          assert_response :success
          assert page.has_content? "Edit settings"
        end
      end
    end
  end
end
