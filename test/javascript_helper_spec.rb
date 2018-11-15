require 'spec_helper'

describe Stripe::JavascriptHelper do
  before { Rails.application.config.stripe.publishable_key = 'pub_xxxx' }
  let(:controller)  { ActionView::TestCase::TestController.new }
  let(:view)        { controller.view_context }

  describe '#stripe_javascript_tag' do
    describe 'when no options are passed' do
      it 'should default to v3' do
        view.stripe_javascript_tag.must_include 'https://js.stripe.com/v3/'
      end
    end

    describe 'when the v2 option is passed' do
      it 'should default to v2' do
        view.stripe_javascript_tag(:v2).must_include 'https://js.stripe.com/v2/'
      end
    end

    describe 'when the debug flag is enabled' do
      before { Rails.application.config.stripe.debug_js = true }
      after  { Rails.application.config.stripe.debug_js = false }
      it 'should render the debug js' do
        view.stripe_javascript_tag(:v1).must_include 'https://js.stripe.com/v1/stripe-debug.js'
      end

      describe 'when v3 is selected' do
        it 'should not render debug js' do
          view.stripe_javascript_tag(:v3).wont_include 'https://js.stripe.com/v1/stripe-debug.js'
        end
      end
    end
  end

  describe "render :partial => 'stripe/js'" do
    subject { view.render :partial => 'stripe/js' }

    it 'should render correctly' do
      subject.must_include 'https://js.stripe.com/v3/'
    end
  end

  describe "render :partial => 'stripe/js', local: {stripe_js_version: 'v2'}" do
    subject { view.render :partial => 'stripe/js', locals: {stripe_js_version: 'v2'} }

    it 'should render correctly' do
      subject.must_include 'https://js.stripe.com/v2/'
    end
  end

  describe '#stripe_elements_tag' do
    describe 'when no options are passed' do
      it 'should display the form' do
        view.stripe_elements_tag(
          submit_path: '/charge',
        ).must_include 'Credit or debit card'
      end
    end

    describe 'with options' do
      describe 'without default js' do
        it 'wont include the default script tag' do
          view.stripe_elements_tag(
            submit_path: '/charge',
            default_js: false
          ).wont_include '<script>'
        end
      end

      describe 'without default css' do
        it 'wont include the default style tag' do
          view.stripe_elements_tag(
            submit_path: '/charge',
            default_css: false
          ).wont_include '<style>'
        end
      end

      describe 'text options' do
        it 'should display the selected text options' do
          page = view.stripe_elements_tag(
            submit_path: '/charge',
            label_text: 'Enter your info',
            submit_button_text: 'Confirm payment'
          )

          page.must_include 'Enter your info'
          page.must_include 'Confirm payment'
        end
      end
    end
  end
end
