require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe 'GET /customers/:id/credit_cards/:credit_card_id/transactions' do
    let(:credit_card) { create(:credit_card) }
    let!(:transactions) { create_list(:transaction, 10, credit_card_id: credit_card.id) }
    let(:customer_id) { credit_card.account.customer.id }
    let(:credit_card_id) { credit_card.id }

    before { get "/customers/#{customer_id}/credit_cards/#{credit_card_id}/transactions" }

    context 'when user exists' do
      context 'when the credit card exists' do
        it 'returns the transactions' do
          expect(json['transactions']).to all( include("credit_card_id" => credit_card.id) )
        end

        include_examples 'http status code', 200
      end

      context 'when the credit card does not exist' do
        let(:credit_card_id) { 0 }

        it 'returns an error message' do
          expect(json['message']).to match(/Couldn't find CreditCard/)
        end

        include_examples 'http status code', 404
      end
    end

    context 'when user does not exist' do
      let(:customer_id) { 0 }

      it 'returns an error message' do
        expect(json['message']).to match(/Couldn't find Customer/)
      end

      include_examples 'http status code', 404
    end

    context 'when you have status parameter' do
      before { get "/customers/#{customer_id}/credit_cards/#{credit_card_id}/transactions?status=paid" }

      it 'returns the filtered transactions given the status' do
        expect(json['transactions']).to all( include("credit_card_id" => credit_card.id, "status" => "paid") )
      end
    end

  end

  describe 'GET /customers/:id/credit_cards/:credit_card_id/charge' do
    let(:credit_card) { create(:credit_card) }
    let(:customer_id) { credit_card.account.customer.id }
    let(:credit_card_id) { credit_card.id }

    before { post "/customers/#{customer_id}/credit_cards/#{credit_card_id}/charge", params: { transaction: { amount: Faker::Number.within(range: 1..10000), currency: Faker::Currency.code } } }

    context 'when user exists' do
      context 'when credit card exists' do
        context 'when the params have the attributes' do
          it 'creates the transaction' do            
            expect(json['transaction']['credit_card_id']).to eq(credit_card.id)
          end

          include_examples 'http status code', 201
        end

        
        context 'when the amount is missing' do
          before { post "/customers/#{customer_id}/credit_cards/#{credit_card_id}/charge", params: { transaction: { currency: Faker::Currency.code } } }

          it 'raises an error message' do         
            expect(json['message']).to match(/comparison of Integer with nil failed/)
          end

          include_examples 'http status code', 422
        end

        context 'when the currency is missing' do
          before { post "/customers/#{customer_id}/credit_cards/#{credit_card_id}/charge", params: { transaction: { amount: Faker::Number.within(range: 1..10000) } } }

          it 'raises an error message' do         
            expect(json).to match([/Currency can't be blank/])
          end

          include_examples 'http status code', 422
        end
      end

      
      context 'when the credit card does not exist' do
        let(:credit_card_id) { 0 }

        it 'returns an error message' do
          expect(json['message']).to match(/Couldn't find CreditCard/)
        end

        include_examples 'http status code', 404
      end
    end

    context 'when user does not exist' do
      let(:customer_id) { 0 }

      it 'returns an error message' do
        expect(json['message']).to match(/Couldn't find Customer/)
      end

      include_examples 'http status code', 404
    end
  end
end
