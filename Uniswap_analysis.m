% Authored by M.F. Fouda, 3/1/2019
% martket making P/L in uniswap ETH-DAI market

clear;
clc;
close all;

initial_committed_capital = 100;
ETH_price0 = 130;

% Source: https://etherscan.io/address/0x09cabec1ead1c0ba254b09efb3ee13841712be14
initial_ETH_pool_size = 5211;
initial_DAI_pool_size = 710951;

initial_pool_size = initial_DAI_pool_size+initial_ETH_pool_size*ETH_price0;

Uniswap_const_product = initial_ETH_pool_size*initial_DAI_pool_size; 
percentage_ownwership = initial_committed_capital/initial_pool_size;

% Commited_DAI*Commited_DAI = Uniswap_const_product
% ETH_price = Commited_DAI/Commited_ETH
% Initial_committed_capital = Commited_DAI + Commited_ETH*ETH_price;

Commited_DAI0 = 0.5*initial_committed_capital;
Commited_ETH0 = 0.5*initial_committed_capital/ETH_price0;

% assuming a change of ETH price with no external change of the liquidity pool size

price_change_ratio= 0.5:0.01:1.5;
trading_vol= linspace(100e3,10e6); % volume between 10k-10M

MM_new_ETH_share = zeros(length(price_change_ratio),length(trading_vol));
MM_new_DAI_share = zeros(length(price_change_ratio),length(trading_vol));

PL = zeros(length(price_change_ratio),length(trading_vol));

for ii = 1:length(price_change_ratio)
    for jj = 1:length(trading_vol)
        ETH_price_change_ratio = price_change_ratio(ii);
        new_ETH_price = ETH_price0*ETH_price_change_ratio;
        
        trading_volume = trading_vol(jj);
        trading_fees = 0.003*trading_volume;
%         Fees added to the pool assuming average price       
%         avg_price_of_move = (ETH_price0+new_ETH_price)/2;
%         ETH_added_to_pool = 0.5*trading_fees/avg_price_of_move;
%         DAI_added_to_pool = 0.5*trading_fees;
        
        % Fees added assuming uniform volume segments during the price move
        no_of_price_steps = 10;
        fees_per_price= trading_fees/no_of_price_steps;
        intermidate_price_steps=linspace(ETH_price0,new_ETH_price,no_of_price_steps);  %assuming linear price increase
        ETH_added_to_pool = sum(0.5*fees_per_price./intermidate_price_steps);
        DAI_added_to_pool = 0.5*trading_fees;
        
        DAI_pool_size = sqrt(Uniswap_const_product*new_ETH_price)+DAI_added_to_pool;
        ETH_pool_size = DAI_pool_size/new_ETH_price+ETH_added_to_pool;
        
        Check = (DAI_pool_size*ETH_pool_size)/Uniswap_const_product;
        
        MM_new_ETH_share(ii,jj) = percentage_ownwership*ETH_pool_size;
        MM_new_DAI_share(ii,jj) = percentage_ownwership*DAI_pool_size;
        
        MM_new_position = MM_new_DAI_share(ii,jj)+MM_new_ETH_share(ii,jj)*new_ETH_price;
        position_without_MM = Commited_DAI0+Commited_ETH0*new_ETH_price;
        
        PL(ii,jj)= MM_new_position-position_without_MM;
    end
end;
figure;
imagesc(trading_vol/1e6,(price_change_ratio-1)*100,PL/initial_committed_capital*100)
ylabel('ETH price change [%]');
xlabel('Trading Volume [$ Million]');