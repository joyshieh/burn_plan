require 'spec_helper'

describe 'uniform distributions' do
  it 'has all zero portfolios' do
    # construct our "world"
    federal_reserve = BurnPlan::FederalReserve.new(0.031, 0.043)

    # from http://www.bogleheads.org/wiki/Historical_and_expected_returns
    economy = BurnPlan::EconomyBuilder.new
    .add_asset_class(BurnPlan::AssetClass.new('Large Company Stock',        0.1230, 0.2020))
    .add_asset_class(BurnPlan::AssetClass.new('Small Company Stocks',       0.1740, 0.3290))
    .add_asset_class(BurnPlan::AssetClass.new('Long-term Corporate Bonds',  0.0620,	0.0850))
    .add_asset_class(BurnPlan::AssetClass.new('Long Term Government Bonds', 0.0550,	0.0570))
    .add_asset_class(BurnPlan::AssetClass.new('U.S. Treasury Bills',        0.0380,	0.0310))
    .build

    # TODO: maybe we shouldn't use floats for money. use int as cents instead with rounding
    portfolio = BurnPlan::PortfolioBuilder.new
    .add_asset(BurnPlan::Asset.new('Large Company Stock',        1_000.0))
    .add_asset(BurnPlan::Asset.new('Small Company Stocks',       1_000.0))
    .add_asset(BurnPlan::Asset.new('Long-term Corporate Bonds',  1_000.0))
    .add_asset(BurnPlan::Asset.new('Long Term Government Bonds', 1_000.0))
    .add_asset(BurnPlan::Asset.new('U.S. Treasury Bills',        1_000.0))
    .build

    # set our life strategies
    # distribution_strategy = BurnPlan::DistributionStrategy::NoDistributionStrategy.new
    distribution_strategy = BurnPlan::DistributionStrategy::UniformDistributionStrategy.new(5_000.0)
    rebalancing_strategy = BurnPlan::RebalancingStrategy::NoRebalancingStrategy.new

    # run the simulations
    num_years_to_live = 70
    life_factory = BurnPlan::LifeFactory.new(portfolio, num_years_to_live, economy, federal_reserve, distribution_strategy, rebalancing_strategy)
    num_simulations = 100
    monte_carlo = BurnPlan::MonteCarlo.new(num_simulations, life_factory)
    results = monte_carlo.run

    # get the results
    class Numeric
      def to_currency( pre_symbol='$', thousands=',', decimal='.',
          post_symbol=nil )
        "#{pre_symbol}#{
        ( "%.2f" % self ).gsub(
            /(\d)(?=(?:\d{3})+(?:$|\.))/,
            "\\1#{thousands}"
        )
        }#{post_symbol}"
      end
    end

    results.ending_portfolio_values_mean.to_currency.should_not be_nil
    results.ending_portfolio_values_num_zeros.should eq num_simulations
  end
end
