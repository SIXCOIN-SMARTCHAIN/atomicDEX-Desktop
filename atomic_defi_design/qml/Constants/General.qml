pragma Singleton
import QtQuick 2.15
import AtomicDEX.TradingError 1.0

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int minimumWidth: 1280
    readonly property int minimumHeight: 800
    readonly property double delta_time: 1000/60

    readonly property string os_file_prefix: Qt.platform.os == "windows" ? "file:///" : "file://"
    readonly property string assets_path: "qrc:///"
    readonly property string image_path: assets_path + "atomic_defi_design/assets/images/"
    readonly property string coin_icons_path: image_path + "coins/"
    readonly property string custom_coin_icons_path: os_file_prefix + API.app.settings_pg.get_custom_coins_icons_path() + "/"

    function coinIcon(ticker) {
        if(ticker === "" || ticker === "All" || ticker===undefined) {
            return ""
        }else {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            return (coin_info.is_custom_coin ? custom_coin_icons_path : coin_icons_path) + atomic_qt_utilities.retrieve_main_ticker(ticker.toString()).toLowerCase() + ".png"
        }
    }

    // Returns the icon full path of a coin type.
    // If the given coin type has spaces, it will be replaced by '-' characters.
    // If the given coin type is empty, returns an empty string.
    function coinTypeIcon(type) {
        if (type === "") return ""

        var filename = type.toLowerCase().replace(" ", "-");
        return coin_icons_path + filename + ".png"
    }

    function qaterialIcon(name) {
        return "qrc:/Qaterial/Icons/" + name + ".svg"
    }

    readonly property string cex_icon: 'ⓘ'
    readonly property string download_icon: '📥'
    readonly property string right_arrow_icon: "⮕"
    readonly property string privacy_text: "*****"

    readonly property string version_string: "Desktop v" + API.app.settings_pg.get_version()

    property bool privacy_mode: false

    readonly property var reg_pass_input: /[A-Za-z0-9@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]+/
    readonly property var reg_pass_valid_low_security: /^(?=.{1,}).*$/
    readonly property var reg_pass_valid: /^(?=.{16,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]).*$/
    readonly property var reg_pass_uppercase: /(?=.*[A-Z])/
    readonly property var reg_pass_lowercase: /(?=.*[a-z])/
    readonly property var reg_pass_numeric: /(?=.*[0-9])/
    readonly property var reg_pass_special: /(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?])/
    readonly property var reg_pass_count_low_security: /(?=.{1,})/
    readonly property var reg_pass_count: /(?=.{16,})/

    readonly property double time_toast_important_error: 10000
    readonly property double time_toast_basic_info: 3000

    readonly property var chart_times: (["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "3d"/*, "1w"*/])
    readonly property var time_seconds: ({ "1m": 60, "3m": 180, "5m": 300, "15m": 900, "30m": 1800, "1h": 3600, "2h": 7200, "4h": 14400, "6h": 21600, "12h": 43200, "1d": 86400, "3d": 259200, "1w": 604800 })


    property bool initialized_orderbook_pair: false
    readonly property string default_base: atomic_app_primary_coin
    readonly property string default_rel: atomic_app_secondary_coin

    function timestampToDouble(timestamp) {
        return (new Date(timestamp)).getTime()
    }

    function timestampToString(timestamp) {
        return (new Date(timestamp)).toUTCString()
    }

    function timestampToDate(timestamp) {
        return (new Date(timestamp * 1000))
    }

    function getDuration(total_ms) {
        let delta = Math.abs(total_ms)

        let days = Math.floor(delta / 86400000)
        delta -= days * 86400000

        let hours = Math.floor(delta / 3600000) % 24
        delta -= hours * 3600000

        let minutes = Math.floor(delta / 60000) % 60
        delta -= minutes * 60000

        let seconds = Math.floor(delta / 1000) % 60
        delta -= seconds * 1000

        let milliseconds = Math.floor(delta)

        return { days, hours, minutes, seconds, milliseconds }
    }

    function secondsToTimeLeft(date_now, date_future) {
        const r = getDuration((date_future - date_now)*1000)
        let days = r.days
        let hours = r.hours
        let minutes = r.minutes
        let seconds = r.seconds

        if(hours < 10) hours = '0' + hours
        if(minutes < 10) minutes = '0' + minutes
        if(seconds < 10) seconds = '0' + seconds
        return qsTr("%n day(s)", "", days) + '  ' + hours + ':' + minutes + ':' + seconds
    }

    function durationTextShort(total) {
        if(!General.exists(total))
            return "-"

        const r = getDuration(total)

        let text = ""
        if(r.days > 0) text += qsTr("%nd", "day", r.days) + "  "
        if(r.hours > 0) text += qsTr("%nh", "hours", r.hours) + "  "
        if(r.minutes > 0) text += qsTr("%nm", "minutes", r.minutes) + "  "
        if(r.seconds > 0) text += qsTr("%ns", "seconds", r.seconds) + "  "
        if(text === "" && r.milliseconds > 0) text += qsTr("%nms", "milliseconds", r.milliseconds) + "  "
        if(text === "") text += qsTr("-")

        return text
    }

    function absString(str) {
        return str.replace("-", "")
    }

    function clone(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    function prettifyJSON(j) {
        const j_obj = typeof j === "string" ? JSON.parse(j) : j
        return JSON.stringify(j_obj, null, 4)
    }

    function viewTxAtExplorer(ticker, id, add_0x=true) {
        if(id !== '') {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            const id_prefix = add_0x && coin_info.type === 'ERC-20' || coin_info.type === 'BEP-20' ? '0x' : ''
            Qt.openUrlExternally(coin_info.explorer_url + coin_info.tx_uri + id_prefix + id)
        }
    }

    function viewAddressAtExplorer(ticker, address) {
        if(address !== '') {
            const coin_info = API.app.portfolio_pg.global_cfg_mdl.get_coin_info(ticker)
            Qt.openUrlExternally(coin_info.explorer_url + coin_info.address_uri + address)
        }
    }

    function diffPrefix(received) {
        return received === "" ? "" : received === true ? "+ " :  "- "
    }

    function filterCoins(list, text, type) {
        return list.filter(c => (c.ticker.indexOf(text.toUpperCase()) !== -1 || c.name.toUpperCase().indexOf(text.toUpperCase()) !== -1) &&
                           (type === undefined || c.type === type)).sort((a, b) => {
                               if(a.ticker < b.ticker) return -1
                               if(a.ticker > b.ticker) return 1
                               return 0
                           })
    }

    function validFiatRates(data, fiat) {
        return data && data.rates && data.rates[fiat]
    }

    function nFormatter(num, digits) {
      if(num < 1E5) return General.formatDouble(num)

      const si = [
        { value: 1, symbol: "" },
        { value: 1E3, symbol: "k" },
        { value: 1E6, symbol: "M" },
        { value: 1E9, symbol: "G" },
        { value: 1E12, symbol: "T" },
        { value: 1E15, symbol: "P" },
        { value: 1E18, symbol: "E" }
      ]
      const rx = /\.0+$|(\.[0-9]*[1-9])0+$/

      let i
      for (i = si.length - 1; i > 0; --i)
        if (num >= si[i].value) break

      return (num / si[i].value).toFixed(digits).replace(rx, "$1") + si[i].symbol
    }

    function formatFiat(received, amount, fiat) {
        return diffPrefix(received) +
                (fiat === API.app.settings_pg.current_fiat ? API.app.settings_pg.current_fiat_sign : API.app.settings_pg.current_currency_sign)
                + " " + nFormatter(parseFloat(amount), 2)
    }

    function formatPercent(value, show_prefix=true) {
        let prefix = ''
        if(value > 0) prefix = '+ '
        else if(value < 0) {
            prefix = '- '
            value *= -1
        }

        return (show_prefix ? prefix : '') + value + ' %'
    }

    readonly property int amountPrecision: 8
    readonly property int sliderDigitLimit: 9
    readonly property int recommendedPrecision: -1337

    function getDigitCount(v) {
        return v.toString().replace("-", "").split(".")[0].length
    }

    function getRecommendedPrecision(v, limit) {
        const lim = limit || sliderDigitLimit
        return Math.min(Math.max(lim - getDigitCount(v), 0), amountPrecision)
    }

    function formatDouble(v, precision, trail_zeros) {
        if(v === '') return "0"
        if(precision === recommendedPrecision) precision = getRecommendedPrecision(v)

        if(precision === 0) return parseInt(v).toString()

        // Remove more than n decimals, then convert to string without trailing zeros
        const full_double = parseFloat(v).toFixed(precision || amountPrecision)

        return trail_zeros ? full_double : full_double.replace(/\.?0+$/,"")
    }

    function formatCrypto(received, amount, ticker, fiat_amount, fiat) {
        return diffPrefix(received) +  atomic_qt_utilities.retrieve_main_ticker(ticker) + " " + formatDouble(amount) + (fiat_amount ? " (" + formatFiat("", fiat_amount, fiat) + ")" : "")
    }

    function fullCoinName(name, ticker) {
        return name + " (" + ticker + ")"
    }

    function fullNamesOfCoins(coins) {
        return coins.map(c => {
         return { value: c.ticker, text: fullCoinName(c.name, c.ticker) }
        })
    }

    function tickersOfCoins(coins) {
        return coins.map(c => {
            return { value: c.ticker, text: c.ticker }
        })
    }

    function getMinTradeAmount() {
        return 0.00777
    }

    function hasEnoughFunds(sell, base, rel, price, volume) {
        if(sell) {
            if(volume === "") return true
            return API.app.do_i_have_enough_funds(base, volume)
        }
        else {
            if(price === "") return true
            const needed_amount = parseFloat(price) * parseFloat(volume)
            return API.app.do_i_have_enough_funds(rel, needed_amount)
        }
    }

    function isZero(v) {
        return !isFilled(v) || parseFloat(v) === 0
    }


    function exists(v) {
        return v !== undefined && v !== null
    }

    function isFilled(v) {
        return exists(v) && v !== ""
    }

    function isParentCoinNeeded(ticker, type) {
        for(const c of API.app.portfolio_pg.get_all_enabled_coins())
            if(c.type === type && c.ticker !== ticker) return true

        return false
    }

    property Timer prevent_coin_disabling: Timer { interval: 5000 }

    function canDisable(ticker) {
        if(prevent_coin_disabling.running)
            return false

        if(ticker === atomic_app_primary_coin || ticker === atomic_app_secondary_coin) return false
        else if(ticker === "ETH") return !General.isParentCoinNeeded("ETH", "ERC-20")
        else if(ticker === "QTUM") return !General.isParentCoinNeeded("QTUM", "QRC-20")

        return true
    }

    function tokenUnitName(type) {
        return type === "ERC-20" ? "Gwei" : "Satoshi"
    }

    function isParentCoin(ticker) {
        return ticker === "KMD" || ticker === "ETH" || ticker === "QTUM"
    }

    function isTokenType(type) {
        return type === "ERC-20" || type === "QRC-20"
    }

    function getParentCoin(type) {
        if(type === "ERC-20") return "ETH"
        else if(type === "QRC-20") return "QTUM"
        else if(type === "Smart Chain") return "KMD"
        return "?"
    }

    function getRandomInt(min, max) {
        min = Math.ceil(min)
        max = Math.floor(max)
        return Math.floor(Math.random() * (max - min + 1)) + min
    }

    function getFiatText(v, ticker, has_info_icon=true) {
        return General.formatFiat('', v === '' ? 0 : API.app.get_fiat_from_amount(ticker, v), API.app.settings_pg.current_fiat)
                + (has_info_icon ? " " +  General.cex_icon : "")
    }

    function hasParentCoinFees(trade_info) {
        return General.isFilled(trade_info.rel_transaction_fees) && parseFloat(trade_info.rel_transaction_fees) > 0
    }

    function feeText(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {


        if(!trade_info || !trade_info.trading_fee) return ""

        const tx_fee = txFeeText(trade_info, base_ticker, has_info_icon, has_limited_space)
        const trading_fee = tradingFeeText(trade_info, base_ticker, has_info_icon)
        const minimum_amount = minimumtradingFeeText(trade_info, base_ticker, has_info_icon)


        return tx_fee + "\n" + trading_fee +"<br>"+minimum_amount
    }

    function txFeeText(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {

        if(!trade_info || !trade_info.trading_fee) return ""

        const has_parent_coin_fees = hasParentCoinFees(trade_info)

         var info =  qsTr('%1 Transaction Fee'.arg(trade_info.base_transaction_fees_ticker))+': '+ trade_info.base_transaction_fees + " (%1)".arg(getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, has_info_icon))

        if (has_parent_coin_fees) {
            info = info+"<br>"+qsTr('%1 Transaction Fee'.arg(trade_info.rel_transaction_fees_ticker))+': '+ trade_info.rel_transaction_fees + " (%1)".arg(getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon))
        }

        return info+"<br>"
//        const main_fee = (qsTr('Transaction Fee') + ': ' + General.formatCrypto("", trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker)) +
//                                 // Rel Fees
//                                 (has_parent_coin_fees ? " + " + General.formatCrypto("", trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker) : '')

//        let fiat_part = "("
//        fiat_part += getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, false)
//        if(has_parent_coin_fees) fiat_part += (has_limited_space ? "\n\t\t+ " : " + ") + getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon)
//        fiat_part += ")"

//        return main_fee + " " + fiat_part
    }
//    function txFeeText2(trade_info, base_ticker, has_info_icon=true, has_limited_space=false) {
//        if(!trade_info || !trade_info.trading_fee) return ""

//        const has_parent_coin_fees = hasParentCoinFees(trade_info)
//        const main_fee = (qsTr('Transaction Fee') + ': ' + General.formatCrypto("", trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker)) +
//                                 // Rel Fees
//                                 (has_parent_coin_fees ? " + " + General.formatCrypto("", trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker) : '')

//        let fiat_part = "("
//        fiat_part += getFiatText(trade_info.base_transaction_fees, trade_info.base_transaction_fees_ticker, false)
//        if(has_parent_coin_fees) fiat_part += (has_limited_space ? "\n\t\t+ " : " + ") + getFiatText(trade_info.rel_transaction_fees, trade_info.rel_transaction_fees_ticker, has_info_icon)
//        fiat_part += ")"

//        return main_fee + " " + fiat_part
//    }

    function tradingFeeText(trade_info, base_ticker, has_info_icon=true) {
        if(!trade_info || !trade_info.trading_fee) return ""

        return trade_info.trading_fee_ticker+" "+qsTr('Trading Fee') + ': ' + General.formatCrypto("", trade_info.trading_fee, "") +

                // Fiat part
                (" ("+
                    getFiatText(trade_info.trading_fee, trade_info.trading_fee_ticker, has_info_icon)
                 +")")
    }
    function minimumtradingFeeText(trade_info, base_ticker, has_info_icon=true) {
        if(!trade_info || !trade_info.trading_fee) return ""

        return API.app.trading_pg.market_pairs_mdl.left_selected_coin+" "+qsTr('Minimum Trading Amount') + ': ' + General.formatCrypto("", API.app.trading_pg.min_trade_vol , "") +

                // Fiat part
                (" ("+
                    getFiatText(API.app.trading_pg.min_trade_vol , API.app.trading_pg.market_pairs_mdl.left_selected_coin, has_info_icon)
                 +")")
    }

    function checkIfWalletExists(name) {
        if(API.app.wallet_mgr.get_wallets().indexOf(name) !== -1)
            return qsTr("Wallet %1 already exists", "WALLETNAME").arg(name)
        return ""
    }

    function getTradingError(error, fee_info, base_ticker, rel_ticker) {
        switch(error) {
        case TradingError.None:
            return ""
        case TradingError.TradingFeesNotEnoughFunds:
            return qsTr("Not enough balance for trading fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.trading_fee, fee_info.trading_fee_ticker))
        case TradingError.TotalFeesNotEnoughFunds:
            return qsTr("Not enough balance for total fees")
        case TradingError.BaseTransactionFeesNotEnough:
            return qsTr("Not enough balance for transaction fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.base_transaction_fees, fee_info.base_transaction_fees_ticker))
        case TradingError.RelTransactionFeesNotEnough:
            return qsTr("Not enough balance for transaction fees: %1", "AMT TICKER").arg(General.formatCrypto("", fee_info.rel_transaction_fees, fee_info.rel_transaction_fees_ticker))
        case TradingError.BalanceIsLessThanTheMinimalTradingAmount:
            return qsTr("Tradable (after fees) %1 balance is lower than minimum trade amount").arg(base_ticker) + " : " + General.getMinTradeAmount()
        case TradingError.PriceFieldNotFilled:
            return qsTr("Please fill the price field")
        case TradingError.VolumeFieldNotFilled:
            return qsTr("Please fill the volume field")
        case TradingError.VolumeIsLowerThanTheMinimum:
            return qsTr("%1 volume is lower than minimum trade amount").arg(base_ticker) + " : " + General.getMinTradeAmount()
        case TradingError.ReceiveVolumeIsLowerThanTheMinimum:
            return qsTr("%1 volume is lower than minimum trade amount").arg(rel_ticker) + " : " + General.getMinTradeAmount()
        default:
            return qsTr("Unknown Error") + ": " + error
        }
    }

    readonly property var supported_pairs: ({
                                                "1INCH/BTC": "BINANCE:1INCHBTC",
                                                "1INCH/ETH": "HUOBI:1INCHETH",
                                                "1INCH/USDT": "BINANCE:1INCHUSD",
                                                "1INCH/BUSD": "BINANCE:1INCHUSD",
                                                "1INCH/USDC": "BINANCE:1INCHUSD",
                                                "1INCH/TUSD": "BINANCE:1INCHUSD",
                                                "1INCH/HUSD": "BINANCE:1INCHUSD",
                                                "1INCH/DAI": "BINANCE:1INCHUSD",
                                                "1INCH/PAX": "BINANCE:1INCHUSD",
                                                "ADA/BTC": "BINANCE:ADABTC",
                                                "ADA/ETH": "BINANCE:ADAETH",
                                                "ADA/BNB": "BINANCE:ADABNB",
                                                "ADA/USDT": "BINANCE:ADAUSDT",
                                                "ADA/BUSD": "BINANCE:ADABUSD",
                                                "ADA/USDC": "BINANCE:ADAUSDC",
                                                "ADA/TUSD": "BINANCE:ADATUSD",
                                                "ADA/HUSD": "HUOBI:ADAHUSD",
                                                "ADA/BCH": "HITBTC:ADABCH",
                                                "AAVE/BTC": "BINANCE:AAVEBTC",
                                                "AAVE/ETH": "BINANCE:AAVEETH",
                                                "AAVE/BNB": "BINANCE:AAVEBNB",
                                                "AAVE/USDT": "BINANCE:AAVEUSD",
                                                "AAVE/BUSD": "BINANCE:AAVEUSD",
                                                "AAVE/USDC": "BINANCE:AAVEUSD",
                                                "AAVE/TUSD": "BINANCE:AAVEUSD",
                                                "AAVE/HUSD": "BINANCE:AAVEUSD",
                                                "AAVE/DAI": "BINANCE:AAVEUSD",
                                                "AAVE/PAX": "BINANCE:AAVEUSD",
                                                "AAVE/EURS": "KRAKEN:AAVEEUR",
                                                "AGI/BTC": "BINANCE:AGIBTC",
                                                "AGI/ETH": "KUCOIN:AGIETH",
                                                "ANT/BTC": "BINANCE:ANTBTC",
                                                "ANT/ETH": "BITFINEX:ANTETH",
                                                "ANT/USDT": "BINANCE:ANTUSD",
                                                "ANT/BUSD": "BINANCE:ANTUSD",
                                                "ANT/USDC": "BINANCE:ANTUSD",
                                                "ANT/TUSD": "BINANCE:ANTUSD",
                                                "ANT/HUSD": "BINANCE:ANTUSD",
                                                "ANT/DAI": "BINANCE:ANTUSD",
                                                "ANT/PAX": "BINANCE:ANTUSD",
                                                "ANT/BNB": "BINANCE:ANTBNB",
                                                "ANT/EURS": "KRAKEN:ANTEUR",
                                                "ARPA/BTC": "BINANCE:ARPABTC",
                                                "ARPA/USDT": "BINANCE:ARPAUSDT",
                                                "ARPA/BNB": "BINANCE:ARPABNB",
                                                "ARPA/HT": "HUOBI:ARPAHT",
                                                "ATOM/BTC": "BINANCE:ATOMBTC",
                                                "ATOM/ETH": "KRAKEN:ATOMETH",
                                                "ATOM/USDT": "COINBASE:ATOMUSD",
                                                "ATOM/BUSD": "COINBASE:ATOMUSD",
                                                "ATOM/USDC": "COINBASE:ATOMUSD",
                                                "ATOM/TUSD": "COINBASE:ATOMUSD",
                                                "ATOM/HUSD": "COINBASE:ATOMUSD",
                                                "ATOM/DAI": "COINBASE:ATOMUSD",
                                                "ATOM/PAX": "COINBASE:ATOMUSD",
                                                "ATOM/BNB": "BINANCE:ATOMBNB",
                                                "ATOM/EURS": "KRAKEN:ATOMEUR",
                                                "ATOM/BCH": "HITBTC:ATOMBCH",
                                                "AVAX/BTC": "BINANCE:AVAXBTC",
                                                "AVAX/ETH": "OKEX:AVAXETH",
                                                "AVAX/USDT": "BINANCE:AVAXUSD",
                                                "AVAX/BUSD": "BINANCE:AVAXUSD",
                                                "AVAX/USDC": "BINANCE:AVAXUSD",
                                                "AVAX/TUSD": "BINANCE:AVAXUSD",
                                                "AVAX/HUSD": "BINANCE:AVAXUSD",
                                                "AVAX/DAI": "BINANCE:AVAXUSD",
                                                "AVAX/PAX": "BINANCE:AVAXUSD",
                                                "AVAX/BNB": "BINANCE:AVAXBNB",
                                                "AVAX/EURS": "BINANCE:AVAXEUR",
                                                "BAL/BTC": "BINANCE:BALBTC",
                                                "BAL/ETH": "HUOBI:BALETH",
                                                "BAL/USDT": "BINANCE:BALUSD",
                                                "BAL/BUSD": "BINANCE:BALUSD",
                                                "BAL/USDC": "BINANCE:BALUSD",
                                                "BAL/TUSD": "BINANCE:BALUSD",
                                                "BAL/HUSD": "BINANCE:BALUSD",
                                                "BAL/DAI": "BINANCE:BALUSD",
                                                "BAL/PAX": "BINANCE:BALUSD",
                                                "BAL/EURS": "KRAKEN:BALEUR",
                                                "BAND/BTC": "BINANCE:BANDBTC",
                                                "BAND/ETH": "HUOBI:BANDETH",
                                                "BAND/BNB": "BINANCE:BANDBNB",
                                                "BAND/USDT": "BINANCE:BANDUSD",
                                                "BAND/BUSD": "BINANCE:BANDUSD",
                                                "BAND/USDC": "BINANCE:BANDUSD",
                                                "BAND/TUSD": "BINANCE:BANDUSD",
                                                "BAND/HUSD": "BINANCE:BANDUSD",
                                                "BAND/DAI": "BINANCE:BANDUSD",
                                                "BAND/PAX": "BINANCE:BANDUSD",
                                                "BAND/EURS": "COINBASE:BANDEUR",
                                                "BAT/BTC": "BINANCE:BATBTC",
                                                "BAT/ETH": "BINANCE:BATETH",
                                                "BAT/BNB": "BINANCE:BATBNB",
                                                "BAT/USDT": "BINANCE:BATUSD",
                                                "BAT/BUSD": "BINANCE:BATUSD",
                                                "BAT/USDC": "BINANCE:BATUSD",
                                                "BAT/TUSD": "BINANCE:BATUSD",
                                                "BAT/HUSD": "BINANCE:BATUSD",
                                                "BAT/DAI": "BINANCE:BATUSD",
                                                "BAT/PAX": "BINANCE:BATUSD",
                                                "BAT/EURS": "KRAKEN:BATEUR",
                                                "BEST/BTC": "BITPANDAPRO:BESTBTC",
                                                "BEST/USDT": "BITTREX:BESTUSDT",
                                                "BCH/BTC": "BINANCE:BCHBTC",
                                                "BCH/ETH": "BITTREX:BCHETH",
                                                "BCH/BNB": "BINANCE:BCHBNB",
                                                "BCH/USDT": "BINANCE:BCHUSDT",
                                                "BCH/BUSD": "BINANCE:BCHBUSD",
                                                "BCH/EURS": "HITBTC:BCHEURS",
                                                "BCH/HUSD": "HUOBI:BCHHUSD",
                                                "BCH/USDC": "BINANCE:BCHUSDC",
                                                "BCH/PAX": "BINANCE:BCHPAX",
                                                "BCH/TUSD": "BINANCE:BCHTUSD",
                                                "BCH/DAI": "HITBTC:BCHDAI",
                                                "BLK/BTC": "BITTREX:BLKBTC",
                                                "BNB/BTC": "BINANCE:BNBBTC",
                                                "BNB/ETH": "BINANCE:BNBETH",
                                                "BNB/USDT": "BINANCE:BNBUSDT",
                                                "BNB/BUSD": "BINANCE:BNBBUSD",
                                                "BNB/DAI": "BINANCE:BNBDAI",
                                                "BNB/PAX": "BINANCE:BNBPAX",
                                                "BNB/TUSD": "BINANCE:BNBTUSD",
                                                "BNB/USDC": "BINANCE:BNBUSDC",
                                                "BNT/BTC": "BINANCE:BNTBTC",
                                                "BNT/ETH": "BINANCE:BNTETH",
                                                "BNT/USDT": "BINANCE:BNTUSD",
                                                "BNT/BUSD": "BINANCE:BNTUSD",
                                                "BNT/USDC": "BINANCE:BNTUSD",
                                                "BNT/TUSD": "BINANCE:BNTUSD",
                                                "BNT/HUSD": "BINANCE:BNTUSD",
                                                "BNT/DAI": "BINANCE:BNTUSD",
                                                "BNT/PAX": "BINANCE:BNTUSD",
                                                "BNT/EURS": "COINBASE:BNTEUR",
                                                "BTC/USDT": "BINANCE:BTCUSDT",
                                                "BTC/BUSD": "BINANCE:BTCBUSD",
                                                "BTC/DAI": "BINANCE:BTCDAI",
                                                "BTC/EURS": "HITBTC:BTCEURS",
                                                "BTC/EUR": "BINANCE:BTCEUR",
                                                "BTC/HUSD": "HUOBI:BTCHUSD",
                                                "BTC/PAX": "BINANCE:BTCPAX",
                                                "BTC/TUSD": "BINANCE:BTCTUSD",
                                                "BTC/USDC": "BINANCE:BTCUSDC",
                                                "BTU/BTC": "BITTREX:BTUBTC",
                                                "CAKE/BTC": "BINANCE:CAKEBTC",
                                                "CAKE/USDT": "BINANCE:CAKEUSD",
                                                "CAKE/BUSD": "BINANCE:CAKEUSD",
                                                "CAKE/USDC": "BINANCE:CAKEUSD",
                                                "CAKE/TUSD": "BINANCE:CAKEUSD",
                                                "CAKE/HUSD": "BINANCE:CAKEUSD",
                                                "CAKE/DAI": "BINANCE:CAKEUSD",
                                                "CAKE/PAX": "BINANCE:CAKEUSD",
                                                "CAKE/BNB": "BINANCE:CAKEBNB",
                                                "CEL/BTC": "HITBTC:CELBTC",
                                                "CEL/ETH": "HITBTC:CELETH",
                                                "CEL/USDT": "BITTREX:CELUSDT",
                                                "CENNZ/BTC": "HITBTC:CENNZBTC",
                                                "CENNZ/ETH": "HITBTC:CENNZETH",
                                                "CENNZ/USDT": "HITBTC:CENNZUSDT",
                                                "CHSB/BTC": "KUCOIN:CHSBBTC",
                                                "CHSB/ETH": "KUCOIN:CHSBETH",
                                                "CHZ/BTC": "BINANCE:CHZBTC",
                                                "CHZ/ETH": "HUOBI:CHZETH",
                                                "CHZ/USDT": "BINANCE:CHZUSDT",
                                                "CHZ/BUSD": "BINANCE:CHZBUSD",
                                                "COMP/BTC": "BINANCE:COMPBTC",
                                                "COMP/ETH": "KRAKEN:COMPETH",
                                                "COMP/USDT": "BINANCE:COMPUSD",
                                                "COMP/BUSD": "BINANCE:COMPUSD",
                                                "COMP/USDC": "BINANCE:COMPUSD",
                                                "COMP/TUSD": "BINANCE:COMPUSD",
                                                "COMP/HUSD": "BINANCE:COMPUSD",
                                                "COMP/DAI": "BINANCE:COMPUSD",
                                                "COMP/PAX": "BINANCE:COMPUSD",
                                                "COMP/EURS": "KRAKEN:COMPEUR",
                                                "CRO/BTC": "BITTREX:CROBTC",
                                                "CRO/ETH": "BITTREX:CROETH",
                                                "CRO/USDT": "OKEX:CROUSDT",
                                                "CRV/BTC": "BINANCE:CRVBTC",
                                                "CRV/ETH": "KRAKEN:CRVETH",
                                                "CRV/USDT": "BINANCE:CRVUSDT",
                                                "CRV/BUSD": "BINANCE:CRVBUSD",
                                                "CRV/HUSD": "HUOBI:CRVHUSD",
                                                "CVC/BTC": "BINANCE:CVCBTC",
                                                "CVC/ETH": "BINANCE:CVCETH",
                                                "CVC/USDT": "BINANCE:CVCUSDT",
                                                "CVC/USDC": "COINBASE:CVCUSDC",
                                                "CVT/BTC": "BITTREX:CVTBTC",
                                                "CVT/ETH": "HITBTC:CVTETH",
                                                "CVT/USDT": "OKEX:CVTUSDT",
                                                "DASH/USDT": "BINANCE:DASHUSDT",
                                                "DASH/BUSD": "BINANCE:DASHBUSD",
                                                "DASH/ETH": "BINANCE:DASHETH",
                                                "DASH/BTC": "BINANCE:DASHBTC",
                                                "DASH/BCH": "HITBTC:DASHBCH",
                                                "DASH/BNB": "BINANCE:DASHBNB",
                                                "DASH/EURS": "HITBTC:DASHEURS",
                                                "DASH/HUSD": "HUOBI:DASHHUSD",
                                                "DASH/USDC": "POLONIEX:DASHUSDC",
                                                "DASH/HT": "HUOBI:DASHHT",
                                                "DOGE/BTC": "BINANCE:DOGEBTC",
                                                "DOGE/ETH": "HITBTC:DOGEETH",
                                                "DOGE/USDT": "BINANCE:DOGEUSD",
                                                "DOGE/BUSD": "BINANCE:DOGEUSD",
                                                "DOGE/USDC": "BINANCE:DOGEUSD",
                                                "DOGE/TUSD": "BINANCE:DOGEUSD",
                                                "DOGE/HUSD": "BINANCE:DOGEUSD",
                                                "DOGE/DAI": "BINANCE:DOGEUSD",
                                                "DOGE/PAX": "BINANCE:DOGEUSD",
                                                "DOGE/EURS": "BINANCE:DOGEEUR",
                                                "DGB/USDT": "BINANCE:DGBUSDT",
                                                "DGB/BUSD": "BINANCE:DGBBUSD",
                                                "DGB/BTC": "BINANCE:DGBBTC",
                                                "DGB/ETH": "BITTREX:DGBETH",
                                                "DGB/BNB": "BINANCE:DGBBNB",
                                                "DGB/TUSD": "HITBTC:DGBTUSD",
                                                "DIA/BTC": "BINANCE:DIABTC",
                                                "DIA/ETH": "OKEX:DIAETH",
                                                "DIA/USDT": "BINANCE:DIAUSDT",
                                                "DIA/BUSD": "BINANCE:DIABUSD",
                                                "DIA/USDC": "UNISWAP:DIAUSDC",
                                                "DODO/BTC": "BINANCE:DODOBTC",
                                                "DODO/USDT": "BINANCE:DODOUSD",
                                                "DODO/BUSD": "BINANCE:DODOUSD",
                                                "DODO/USDC": "BINANCE:DODOUSD",
                                                "DODO/TUSD": "BINANCE:DODOUSD",
                                                "DODO/HUSD": "BINANCE:DODOUSD",
                                                "DODO/DAI": "BINANCE:DODOUSD",
                                                "DODO/PAX": "BINANCE:DODOUSD",
                                                "DOT/BTC": "BINANCE:DOTBTC",
                                                "DOT/ETH": "KRAKEN:DOTETH",
                                                "DOT/USDT": "BINANCE:DOTUSD",
                                                "DOT/BUSD": "BINANCE:DOTUSD",
                                                "DOT/USDC": "BINANCE:DOTUSD",
                                                "DOT/TUSD": "BINANCE:DOTUSD",
                                                "DOT/HUSD": "BINANCE:DOTUSD",
                                                "DOT/DAI": "BINANCE:DOTUSD",
                                                "DOT/PAX": "BINANCE:DOTUSD",
                                                "DOT/BNB": "BINANCE:DOTBNB",
                                                "DX/BTC": "KUCOIN:DXBTC",
                                                "DX/ETH": "KUCOIN:DXETH",
                                                "EGLD/BTC": "BINANCE:EGLDBTC",
                                                "EGLD/USDT": "BINANCE:EGLDUSD",
                                                "EGLD/BUSD": "BINANCE:EGLDUSD",
                                                "EGLD/USDC": "BINANCE:EGLDUSD",
                                                "EGLD/TUSD": "BINANCE:EGLDUSD",
                                                "EGLD/HUSD": "BINANCE:EGLDUSD",
                                                "EGLD/DAI": "BINANCE:EGLDUSD",
                                                "EGLD/PAX": "BINANCE:EGLDUSD",
                                                "EGLD/BNB": "BINANCE:EGLDBNB",
                                                "EGLD/EURS": "BINANCE:EGLDEUR",
                                                "ELF/BTC": "BINANCE:ELFBTC",
                                                "ELF/ETH": "BINANCE:ELFETH",
                                                "ELF/USDT": "BINANCE:ELFUSD",
                                                "ELF/BUSD": "BINANCE:ELFUSD",
                                                "ELF/USDC": "BINANCE:ELFUSD",
                                                "ELF/TUSD": "BINANCE:ELFUSD",
                                                "ELF/HUSD": "BINANCE:ELFUSD",
                                                "ELF/DAI": "BINANCE:ELFUSD",
                                                "ELF/PAX": "BINANCE:ELFUSD",
                                                "EMC2/BTC": "BITTREX:EMC2BTC",
                                                "ENJ/BTC": "BINANCE:ENJBTC",
                                                "ENJ/ETH": "BINANCE:ENJETH",
                                                "ENJ/USDT": "BINANCE:ENJUSD",
                                                "ENJ/BUSD": "BINANCE:ENJUSD",
                                                "ENJ/USDC": "BINANCE:ENJUSD",
                                                "ENJ/TUSD": "BINANCE:ENJUSD",
                                                "ENJ/HUSD": "BINANCE:ENJUSD",
                                                "ENJ/DAI": "BINANCE:ENJUSD",
                                                "ENJ/PAX": "BINANCE:ENJUSD",
                                                "ENJ/BNB": "BINANCE:ENJBNB",
                                                "ENJ/EURS": "BINANCE:ENJEUR",
                                                "EOS/BTC": "BINANCE:EOSBTC",
                                                "EOS/ETH": "BINANCE:EOSETH",
                                                "EOS/BNB": "BINANCE:EOSBNB",
                                                "EOS/USDT": "BINANCE:EOSUSDT",
                                                "EOS/BUSD": "BINANCE:EOSBUSD",
                                                "EOS/USDC": "BINANCE:EOSUSDC",                                                
                                                "EOS/TUSD": "BINANCE:EOSTUSD",
                                                "EOS/HUSD": "HUOBI:EOSHUSD",
                                                "EOS/BCH": "HITBTC:EOSBCH",                                                
                                                "EOS/DAI": "HITBTC:EOSDAI",
                                                "EOS/PAX": "HITBTC:EOSPAX",
                                                "EOS/EURS": "HITBTC:EOSEURS",
                                                "ETC/BTC": "BINANCE:ETCBTC",
                                                "ETC/ETH": "BINANCE:ETCETH",
                                                "ETC/USDT": "BINANCE:ETCUSD",
                                                "ETC/BUSD": "BINANCE:ETCUSD",
                                                "ETC/USDC": "BINANCE:ETCUSD",
                                                "ETC/TUSD": "BINANCE:ETCUSD",
                                                "ETC/HUSD": "BINANCE:ETCUSD",
                                                "ETC/DAI": "BINANCE:ETCUSD",
                                                "ETC/PAX": "BINANCE:ETCUSD",
                                                "ETC/BNB": "BINANCE:ETCBNB",
                                                "ETC/EURS": "KRAKEN:ETCEUR",
                                                "ETC/BCH": "HITBTC:ETCBCH",
                                                "ETH/BTC": "BINANCE:ETHBTC",
                                                "ETH/USDT": "BINANCE:ETHUSDT",
                                                "ETH/BUSD": "BINANCE:ETHBUSD",
                                                "ETH/DAI": "BINANCE:ETHDAI",
                                                "ETH/EURS": "HITBTC:ETHEURS",
                                                "ETH/HUSD": "HUOBI:ETHHUSD",
                                                "ETH/PAX": "BINANCE:ETHPAX",
                                                "ETH/TUSD": "BINANCE:ETHTUSD",
                                                "ETH/USDC": "BINANCE:ETHUSDC",
                                                "EURS/USDT": "HITBTC:EURSUSDT",
                                                "EURS/DAI": "HITBTC:EURSDAI",
                                                "EURS/TUSD": "HITBTC:EURSTUSD",
                                                "FET/BTC": "BINANCE:FETBTC",
                                                "FET/ETH": "KUCOIN:FETETH",
                                                "FET/USDT": "BINANCE:FETUSDT",
                                                "FIL/BTC": "BINANCE:FILBTC",
                                                "FIL/ETH": "HUOBI:FILETH",
                                                "FIL/USDT": "BINANCE:FILUSD",
                                                "FIL/BUSD": "BINANCE:FILUSD",
                                                "FIL/USDC": "BINANCE:FILUSD",
                                                "FIL/TUSD": "BINANCE:FILUSD",
                                                "FIL/HUSD": "BINANCE:FILUSD",
                                                "FIL/DAI": "BINANCE:FILUSD",
                                                "FIL/PAX": "BINANCE:FILUSD",
                                                "FIL/BNB": "BINANCE:FILBNB",
                                                "FIL/EURS": "COINBASE:FILEUR",
                                                "FIRO/BTC": "BINANCE:FIROBTC",
                                                "FIRO/ETH": "BINANCE:FIROETH",
                                                "FIRO/USDT": "BITTREX:FIROUSD",
                                                "FIRO/BUSD": "BITTREX:FIROUSD",
                                                "FIRO/USDC": "BITTREX:FIROUSD",
                                                "FIRO/TUSD": "BITTREX:FIROUSD",
                                                "FIRO/HUSD": "BITTREX:FIROUSD",
                                                "FIRO/DAI": "BITTREX:FIROUSD",
                                                "FIRO/PAX": "BITTREX:FIROUSD",
                                                "FTC/BTC": "BITTREX:FTCBTC",
                                                "FUN/BTC": "BINANCE:FUNBTC",
                                                "FUN/ETH": "BINANCE:FUNETH",
                                                "FUN/USDT": "BINANCE:FUNUSDT",
                                                "GLEEC/BTC": "BITTREX:GLEECBTC",
                                                "GLEEC/USDT": "BITTREX:GLEECUSDT",
                                                "GNO/BTC": "BITTREX:GNOBTC",
                                                "GNO/ETH": "KRAKEN:GNOETH",
                                                "GRS/BTC": "BINANCE:GRSBTC",
                                                "GRS/ETH": "HUOBI:GRSETH",
                                                "HEX/BTC": "HITBTC:HEXBTC",
                                                "HEX/USDC": "UNISWAP:HEXUSDC",
                                                "HOT/BTC": "HUOBI:HOTBTC",
                                                "HOT/ETH": "BINANCE:HOTETH",
                                                "HOT/USDT": "BINANCE:HOTUSDT",
                                                "HT/BTC": "HUOBI:HTBTC",
                                                "HT/ETH": "HUOBI:HTETH",
                                                "HT/USDT": "HUOBI:HTUSDT",
                                                "HT/HUSD": "HUOBI:HTHUSD",
                                                "INK/BTC": "HITBTC:INKBTC",
                                                "INK/ETH": "HITBTC:INKETH",
                                                "INK/USDT": "HITBTC:INKUSDT",
                                                "IOTA/BTC": "BINANCE:IOTABTC",
                                                "IOTA/ETH": "BINANCE:IOTAETH",
                                                "IOTA/USDT": "BINANCE:IOTAUSD",
                                                "IOTA/BUSD": "BINANCE:IOTAUSD",
                                                "IOTA/USDC": "BINANCE:IOTAUSD",
                                                "IOTA/TUSD": "BINANCE:IOTAUSD",
                                                "IOTA/HUSD": "BINANCE:IOTAUSD",
                                                "IOTA/DAI": "BINANCE:IOTAUSD",
                                                "IOTA/PAX": "BINANCE:IOTAUSD",
                                                "IOTA/BNB": "BINANCE:IOTABNB",
                                                "IOTA/EURS": "BITPANDAPRO:MIOTAEUR",
                                                "IOTX/BTC": "BINANCE:IOTXBTC",
                                                "IOTX/ETH": "BINANCE:IOTXETH",
                                                "IOTX/USDT": "BINANCE:IOTXUSD",
                                                "IOTX/BUSD": "BINANCE:IOTXUSD",
                                                "IOTX/USDC": "BINANCE:IOTXUSD",
                                                "IOTX/TUSD": "BINANCE:IOTXUSD",
                                                "IOTX/HUSD": "BINANCE:IOTXUSD",
                                                "IOTX/DAI": "BINANCE:IOTXUSD",
                                                "IOTX/PAX": "BINANCE:IOTXUSD",
                                                "KMD/BTC": "BINANCE:KMDBTC",
                                                "KMD/ETH": "BINANCE:KMDETH",
                                                "KMD/USDT": "BINANCE:KMDUSD",
                                                "KMD/BUSD": "BINANCE:KMDUSD",
                                                "KMD/USDC": "BINANCE:KMDUSD",
                                                "KMD/TUSD": "BINANCE:KMDUSD",
                                                "KMD/HUSD": "BINANCE:KMDUSD",
                                                "KMD/DAI": "BINANCE:KMDUSD",
                                                "KMD/PAX": "BINANCE:KMDUSD",
                                                "KNC/BTC": "BINANCE:KNCBTC",
                                                "KNC/ETH": "BINANCE:KNCETH",
                                                "KNC/USDT": "BINANCE:KNCUSDT",
                                                "KNC/BUSD": "BINANCE:KNCBUSD",
                                                "KNC/HUSD": "HUOBI:KNCHUSD",
                                                "LEO/BTC": "BITFINEX:LEOBTC",
                                                "LEO/ETH": "BITFINEX:LEOETH",
                                                "LEO/USDT": "OKEX:LEOUSDT",
                                                "LINK/BTC": "BINANCE:LINKBTC",
                                                "LINK/ETH": "BINANCE:LINKETH",
                                                "LINK/BCH": "HITBTC:LINKBCH",
                                                "LINK/USDT": "BINANCE:LINKUSD",
                                                "LINK/BUSD": "BINANCE:LINKUSD",
                                                "LINK/USDC": "BINANCE:LINKUSD",
                                                "LINK/TUSD": "BINANCE:LINKUSD",
                                                "LINK/HUSD": "BINANCE:LINKUSD",
                                                "LINK/DAI": "BINANCE:LINKUSD",
                                                "LINK/PAX": "BINANCE:LINKUSD",
                                                "LINK/EURS": "KRAKEN:LINKEUR",
                                                "LRC/BTC": "BINANCE:LRCBTC",
                                                "LRC/ETH": "BINANCE:LRCETH",
                                                "LRC/USDT": "BINANCE:LRCUSDT",
                                                "LRC/BUSD": "BINANCE:LRCBUSD",
                                                "LTC/BTC": "BINANCE:LTCBTC",
                                                "LTC/ETH": "BINANCE:LTCETH",
                                                "LTC/BNB": "BINANCE:LTCBNB",
                                                "LTC/USDT": "BINANCE:LTCUSDT",
                                                "LTC/BUSD": "BINANCE:LTCBUSD",
                                                "LTC/DAI": "HITBTC:LTCDAI",
                                                "LTC/EURS": "HITBTC:LTCEURS",
                                                "LTC/HUSD": "HUOBI:LTCHUSD",
                                                "LTC/PAX": "BINANCE:LTCPAX",
                                                "LTC/TUSD": "BINANCE:LTCTUSD",
                                                "LTC/USDC": "BINANCE:LTCUSDC",
                                                "LTC/BCH": "HITBTC:LTCBCH",
                                                "LTC/HT": "HUOBI:LTCHT",
                                                "MANA/BTC": "BINANCE:MANABTC",
                                                "MANA/ETH": "BINANCE:MANAETH",
                                                "MANA/USDT": "BINANCE:MANAUSDT",
                                                "MANA/BUSD": "BINANCE:MANABUSD",
                                                "MANA/USDC": "COINBASE:MANAUSDC",
                                                "MATIC/BTC": "BINANCE:MATICBTC",
                                                "MATIC/ETH": "HUOBI:MATICETH",
                                                "MATIC/USDT": "BINANCE:MATICUSD",
                                                "MATIC/BUSD": "BINANCE:MATICUSD",
                                                "MATIC/USDC": "BINANCE:MATICUSD",
                                                "MATIC/TUSD": "BINANCE:MATICUSD",
                                                "MATIC/HUSD": "BINANCE:MATICUSD",
                                                "MATIC/DAI": "BINANCE:MATICUSD",
                                                "MATIC/PAX": "BINANCE:MATICUSD",
                                                "MATIC/BNB": "BINANCE:MATICBNB",
                                                "MATIC/EURS": "COINBASE:MATICEUR",
                                                "MED/BTC": "BITTREX:MEDBTC",
                                                "MKR/BTC": "BINANCE:MKRBTC",
                                                "MKR/ETH": "BITFINEX:MKRETH",
                                                "MKR/BNB": "BINANCE:MKRBNB",
                                                "MKR/USDT": "BINANCE:MKRUSD",
                                                "MKR/BUSD": "BINANCE:MKRUSD",
                                                "MKR/USDC": "BINANCE:MKRUSD",
                                                "MKR/TUSD": "BINANCE:MKRUSD",
                                                "MKR/HUSD": "BINANCE:MKRUSD",
                                                "MKR/DAI": "BINANCE:MKRUSD",
                                                "MKR/PAX": "BINANCE:MKRUSD",
                                                "MKR/EURS": "BITSTAMP:MKREUR",
                                                "MONA/BTC": "BITTREX:MONABTC",
                                                "NAV/BTC": "BINANCE:NAVBTC",
                                                "NAV/USDT": "BINANCE:NAVUSD",
                                                "NAV/BUSD": "BINANCE:NAVUSD",
                                                "NAV/USDC": "BINANCE:NAVUSD",
                                                "NAV/TUSD": "BINANCE:NAVUSD",
                                                "NAV/HUSD": "BINANCE:NAVUSD",
                                                "NAV/DAI": "BINANCE:NAVUSD",
                                                "NAV/PAX": "BINANCE:NAVUSD",
                                                "NEAR/BTC": "BINANCE:NEARBTC",
                                                "NEAR/ETH": "OKEX:NEARETH",
                                                "NEAR/USDT": "BINANCE:NEARUSD",
                                                "NEAR/BUSD": "BINANCE:NEARUSD",
                                                "NEAR/USDC": "BINANCE:NEARUSD",
                                                "NEAR/TUSD": "BINANCE:NEARUSD",
                                                "NEAR/HUSD": "BINANCE:NEARUSD",
                                                "NEAR/DAI": "BINANCE:NEARUSD",
                                                "NEAR/PAX": "BINANCE:NEARUSD",
                                                "NEAR/BNB": "BINANCE:NEARBNB",
                                                "NPXS/BTC": "HUOBI:NPXSBTC",
                                                "NPXS/ETH": "BINANCE:NPXSETH",
                                                "NPXS/USDT": "BINANCE:NPXSUSDT",
                                                "OCEAN/BTC": "BINANCE:OCEANBTC",
                                                "OCEAN/ETH": "KUCOIN:OCEANETH",
                                                "OCEAN/USDT": "BINANCE:OCEANUSDT",
                                                "OCEAN/BUSD": "BINANCE:OCEANBUSD",
                                                "OKB/BTC": "OKEX:OKBBTC",
                                                "OKB/ETH": "OKEX:OKBETH",
                                                "OKB/USDT": "OKEX:OKBUSDT",
                                                "OKB/USDC": "OKEX:OKBUSDC",
                                                "ONT/BTC": "BINANCE:ONTBTC",
                                                "ONT/ETH": "BINANCE:ONTETH",
                                                "ONT/USDT": "BINANCE:ONTUSD",
                                                "ONT/BUSD": "BINANCE:ONTUSD",
                                                "ONT/USDC": "BINANCE:ONTUSD",
                                                "ONT/TUSD": "BINANCE:ONTUSD",
                                                "ONT/HUSD": "BINANCE:ONTUSD",
                                                "ONT/DAI": "BINANCE:ONTUSD",
                                                "ONT/PAX": "BINANCE:ONTUSD",
                                                "ONT/BNB": "BINANCE:ONTBNB",
                                                "ONT/BCH": "HITBTC:ONTBCH",
                                                "PAXG/BTC": "BINANCE:PAXGBTC",
                                                "PAXG/ETH": "KRAKEN:PAXGETH",
                                                "PAXG/USDT": "KRAKEN:PAXGUSD",
                                                "PAXG/BUSD": "KRAKEN:PAXGUSD",
                                                "PAXG/USDC": "KRAKEN:PAXGUSD",
                                                "PAXG/TUSD": "KRAKEN:PAXGUSD",
                                                "PAXG/HUSD": "KRAKEN:PAXGUSD",
                                                "PAXG/DAI": "KRAKEN:PAXGUSD",
                                                "PAXG/PAX": "KRAKEN:PAXGUSD",
                                                "PAXG/BNB": "BINANCE:PAXGBNB",
                                                "PAXG/EURS": "KRAKEN:PAXGEUR",
                                                "PNK/BTC": "BITFINEX:PNKBTC",
                                                "PNK/ETH": "BITFINEX:PNKETH",
                                                "PNK/USDT": "OKEX:PNKUSDT",
                                                "POWR/BTC": "BINANCE:POWRBTC",
                                                "POWR/ETH": "BINANCE:POWRETH",
                                                "QKC/BTC": "BINANCE:QKCBTC",
                                                "QKC/ETH": "BINANCE:QKCETH",
                                                "QNT/BTC": "BITTREX:QNTBTC",
                                                "QNT/USDT": "KUCOIN:QNTUSDT",
                                                "QTUM/BTC": "BINANCE:QTUMBTC",
                                                "QTUM/ETH": "BINANCE:QTUMETH",
                                                "QTUM/USDT": "BINANCE:QTUMUSD",
                                                "QTUM/BUSD": "BINANCE:QTUMUSD",
                                                "QTUM/USDC": "BINANCE:QTUMUSD",
                                                "QTUM/TUSD": "BINANCE:QTUMUSD",
                                                "QTUM/HUSD": "BINANCE:QTUMUSD",
                                                "QTUM/DAI": "BINANCE:QTUMUSD",
                                                "QTUM/PAX": "BINANCE:QTUMUSD",
                                                "QTUM/EURS": "KRAKEN:QTUMEUR",
                                                "REN/BTC": "BINANCE:RENBTC",
                                                "REN/ETH": "HUOBI:RENETH",
                                                "REN/USDT": "BINANCE:RENUSDT",
                                                "REN/HUSD": "HUOBI:RENHUSD",
                                                "REP/BTC": "BINANCE:REPBTC",
                                                "REP/ETH": "BINANCE:REPETH",
                                                "REP/USDT": "BINANCE:REPUSDT",
                                                "REV/BTC": "BITTREX:REVBTC",
                                                "REV/USDT": "KUCOIN:REVUSDT",
                                                "RLC/BTC": "BINANCE:RLCBTC",
                                                "RLC/ETH": "BINANCE:RLCETH",
                                                "RLC/USDT": "BINANCE:RLCUSDT",
                                                "RSR/BTC": "BINANCE:RSRBTC",
                                                "RSR/ETH": "OKEX:RSRETH",
                                                "RSR/USDT": "BINANCE:RSRUSDT",
                                                "RSR/BUSD": "BINANCE:RSRBUSD",
                                                "RSR/HUSD": "HUOBI:RSRHUSD",
                                                "RSR/BNB": "BINANCE:RSRBNB",
                                                "RVN/BTC": "BINANCE:RVNBTC",
                                                "RVN/USDT": "BINANCE:RVNUSD",
                                                "RVN/BUSD": "BINANCE:RVNUSD",
                                                "RVN/USDC": "BINANCE:RVNUSD",
                                                "RVN/TUSD": "BINANCE:RVNUSD",
                                                "RVN/HUSD": "BINANCE:RVNUSD",
                                                "RVN/DAI": "BINANCE:RVNUSD",
                                                "RVN/PAX": "BINANCE:RVNUSD",
                                                "RVN/BNB": "BINANCE:RVNBNB",
                                                "RVN/HT": "HUOBI:RVNHT",
                                                "SHR/BTC": "KUCOIN:SHRBTC",
                                                "SHR/USDT": "KUCOIN:SHRUSDT",
                                                "SKL/BTC": "BINANCE:SKLBTC",
                                                "SKL/ETH": "HUOBI:SKLETH",
                                                "SKL/USDT": "BINANCE:SKLUSDT",
                                                "SKL/BUSD": "BINANCE:SKLBUSD",
                                                "SNT/BTC": "BINANCE:SNTBTC",
                                                "SNT/ETH": "BINANCE:SNTETH",
                                                "SNT/USDT": "HUOBI:SNTUSDT",
                                                "SNX/BTC": "BINANCE:SNXBTC",
                                                "SNX/ETH": "KRAKEN:SNXETH",
                                                "SNX/BNB": "BINANCE:SNXBNB",
                                                "SNX/USDT": "BINANCE:SNXUSD",
                                                "SNX/BUSD": "BINANCE:SNXUSD",
                                                "SNX/USDC": "BINANCE:SNXUSD",
                                                "SNX/TUSD": "BINANCE:SNXUSD",
                                                "SNX/HUSD": "BINANCE:SNXUSD",
                                                "SNX/DAI": "BINANCE:SNXUSD",
                                                "SNX/PAX": "BINANCE:SNXUSD",
                                                "SNX/EURS": "KRAKEN:SNXEUR",
                                                "SPC/BTC": "BITTREX:SPCBTC",
                                                "SPC/ETH": "HITBTC:SPCETH",
                                                "SPC/USDT": "HITBTC:SPCUSDT",
                                                "SRM/BTC": "BINANCE:SRMBTC",
                                                "SRM/USDT": "BINANCE:SRMUSDT",
                                                "SRM/BUSD": "BINANCE:SRMBUSD",
                                                "STORJ/BTC": "BINANCE:STORJBTC",
                                                "STORJ/ETH": "KRAKEN:STORJETH",
                                                "STORJ/USDT": "BINANCE:STORJUSD",
                                                "STORJ/BUSD": "BINANCE:STORJUSD",
                                                "STORJ/USDC": "BINANCE:STORJUSD",
                                                "STORJ/TUSD": "BINANCE:STORJUSD",
                                                "STORJ/HUSD": "BINANCE:STORJUSD",
                                                "STORJ/DAI": "BINANCE:STORJUSD",
                                                "STORJ/PAX": "BINANCE:STORJUSD",
                                                "STORJ/EURS": "KRAKEN:STORJEUR",
                                                "SUSHI/BTC": "BINANCE:SUSHIBTC",
                                                "SUSHI/ETH": "HUOBI:SUSHIETH",
                                                "SUSHI/USDT": "BINANCE:SUSHIUSD",
                                                "SUSHI/BUSD": "BINANCE:SUSHIUSD",
                                                "SUSHI/USDC": "BINANCE:SUSHIUSD",
                                                "SUSHI/TUSD": "BINANCE:SUSHIUSD",
                                                "SUSHI/HUSD": "BINANCE:SUSHIUSD",
                                                "SUSHI/DAI": "BINANCE:SUSHIUSD",
                                                "SUSHI/PAX": "BINANCE:SUSHIUSD",
                                                "SUSHI/BNB": "BINANCE:SUSHIBNB",
                                                "SUSHI/EURS": "COINBASE:SUSHIEUR",
                                                "SXP/BTC": "BINANCE:SXPBTC",
                                                "SXP/BNB": "BINANCE:SXPBNB",
                                                "SXP/USDT": "BINANCE:SXPUSD",
                                                "SXP/BUSD": "BINANCE:SXPUSD",
                                                "SXP/USDC": "BINANCE:SXPUSD",
                                                "SXP/TUSD": "BINANCE:SXPUSD",
                                                "SXP/HUSD": "BINANCE:SXPUSD",
                                                "SXP/DAI": "BINANCE:SXPUSD",
                                                "SXP/PAX": "BINANCE:SXPUSD",
                                                "SXP/EURS": "BINANCE:SXPEUR",
                                                "SYS/BTC": "BINANCE:SYSBTC",
                                                "SYS/USDT": "BINANCE:SYSUSD",
                                                "SYS/BUSD": "BINANCE:SYSUSD",
                                                "SYS/USDC": "BINANCE:SYSUSD",
                                                "SYS/TUSD": "BINANCE:SYSUSD",
                                                "SYS/HUSD": "BINANCE:SYSUSD",
                                                "SYS/DAI": "BINANCE:SYSUSD",
                                                "SYS/PAX": "BINANCE:SYSUSD",
                                                "TMTG/BTC": "OKEX:TMTGBTC",
                                                "TMTG/USDT": "OKEX:TMTGUSDT",
                                                "TRAC/BTC": "KUCOIN:TRACBTC",
                                                "TRAC/ETH": "KUCOIN:TRACETH",
                                                "TRAC/USDT": "BITTREX:TRACUSDT",
                                                "THC/BTC": "BITTREX:THCBTC",
                                                "UBT/BTC": "BITTREX:UBTBTC",
                                                "UBT/ETH": "BITTREX:UBTETH",
                                                "UMA/BTC": "BINANCE:UMABTC",
                                                "UMA/ETH": "OKEX:UMAETH",
                                                "UMA/USDT": "BINANCE:UMAUSDT",
                                                "UNI/BTC": "BINANCE:UNIBTC",
                                                "UNI/ETH": "KRAKEN:UNIETH",
                                                "UNI/BNB": "BINANCE:UNIBNB",
                                                "UNI/USDT": "BINANCE:UNIUSDT",
                                                "UNI/BUSD": "BINANCE:UNIBUSD",
                                                "UOS/BTC": "BITFINEX:UOSBTC",
                                                "UOS/USDT": "KUCOIN:UOSUSDT",
                                                "UQC/BTC": "BITTREX:UQCBTC",
                                                "UQC/ETH": "KUCOIN:UQCETH",
                                                "UQC/USDT": "BITTREX:UQCUSDT",
                                                "USDC/EURS": "UNISWAP:USDCEURS",
                                                "UTK/BTC": "BINANCE:UTKBTC",
                                                "UTK/ETH": "KUCOIN:UTKETH",
                                                "UTK/USDT": "BINANCE:UTKUSDT",
                                                "VRA/BTC": "KUCOIN:VRABTC",
                                                "VRA/ETH": "HITBTC:VRAETH",
                                                "VRA/USDT": "KUCOIN:VRAUSDT",
                                                "WBTC/BTC": "BINANCE:WBTCBTC",
                                                "WBTC/ETH": "BINANCE:WBTCETH",
                                                "WBTC/USDT": "BITTREX:WBTCUSDT",
                                                "WBTC/USDC": "UNISWAP:WBTCUSDC",
                                                "XRP/BTC": "BINANCE:XRPBTC",
                                                "XRP/ETH": "BINANCE:XRPETH",
                                                "XRP/USDT": "BINANCE:XRPUSDT",
                                                "XRP/BUSD": "BINANCE:XRPBUSD",
                                                "XRP/DAI": "HITBTC:XRPDAI",
                                                "XRP/PAX": "BINANCE:XRPPAX",
                                                "XRP/TUSD": "BINANCE:XRPTUSD",
                                                "XRP/USDC": "BINANCE:XRPUSDC",
                                                "XRP/EURS": "HITBTC:XRPEURS",
                                                "XRP/HUSD": "HUOBI:XRPHUSD",
                                                "XRP/BCH": "HITBTC:XRPBCH",
                                                "XTZ/BTC": "BINANCE:XTZBTC",
                                                "XTZ/ETH": "KRAKEN:XTZETH",
                                                "XTZ/USDT": "COINBASE:XTZUSD",
                                                "XTZ/BUSD": "COINBASE:XTZUSD",
                                                "XTZ/USDC": "COINBASE:XTZUSD",
                                                "XTZ/TUSD": "COINBASE:XTZUSD",
                                                "XTZ/HUSD": "COINBASE:XTZUSD",
                                                "XTZ/DAI": "COINBASE:XTZUSD",
                                                "XTZ/PAX": "COINBASE:XTZUSD",
                                                "XTZ/BNB": "BINANCE:XTZBNB",
                                                "XTZ/EURS": "KRAKEN:XTZEUR",
                                                "XVS/BTC": "BINANCE:XVSBTC",
                                                "XVS/USDT": "BINANCE:XVSUSD",
                                                "XVS/BUSD": "BINANCE:XVSUSD",
                                                "XVS/USDC": "BINANCE:XVSUSD",
                                                "XVS/TUSD": "BINANCE:XVSUSD",
                                                "XVS/HUSD": "BINANCE:XVSUSD",
                                                "XVS/DAI": "BINANCE:XVSUSD",
                                                "XVS/PAX": "BINANCE:XVSUSD",
                                                "XVS/BNB": "BINANCE:XVSBNB",
                                                "YFI/BTC": "BINANCE:YFIBTC",
                                                "YFI/ETH": "HUOBI:YFIETH",
                                                "YFI/BNB": "BINANCE:YFIBNB",
                                                "YFI/USDT": "BINANCE:YFIUSD",
                                                "YFI/BUSD": "BINANCE:YFIUSD",
                                                "YFI/USDC": "BINANCE:YFIUSD",
                                                "YFI/TUSD": "BINANCE:YFIUSD",
                                                "YFI/HUSD": "BINANCE:YFIUSD",
                                                "YFI/DAI": "BINANCE:YFIUSD",
                                                "YFI/PAX": "BINANCE:YFIUSD",
                                                "YFI/EURS": "KRAKEN:YFIEUR",
                                                "YFII/BTC": "BINANCE:YFIIBTC",
                                                "YFII/ETH": "HUOBI:YFIIETH",
                                                "YFII/BNB": "BINANCE:YFIIBNB",
                                                "YFII/USDT": "BINANCE:YFIIUSD",
                                                "YFII/BUSD": "BINANCE:YFIIUSD",
                                                "YFII/USDC": "BINANCE:YFIIUSD",
                                                "YFII/TUSD": "BINANCE:YFIIUSD",
                                                "YFII/HUSD": "BINANCE:YFIIUSD",
                                                "YFII/DAI": "BINANCE:YFIIUSD",
                                                "YFII/PAX": "BINANCE:YFIIUSD",
                                                "ZEC/BTC": "BINANCE:ZECBTC",
                                                "ZEC/ETH": "BINANCE:ZECETH",
                                                "ZEC/USDT": "KRAKEN:ZECUSD",
                                                "ZEC/BUSD": "KRAKEN:ZECUSD",
                                                "ZEC/USDC": "KRAKEN:ZECUSD",
                                                "ZEC/TUSD": "KRAKEN:ZECUSD",
                                                "ZEC/HUSD": "KRAKEN:ZECUSD",
                                                "ZEC/DAI": "KRAKEN:ZECUSD",
                                                "ZEC/PAX": "KRAKEN:ZECUSD",
                                                "ZEC/BNB": "BINANCE:ZECBNB",
                                                "ZEC/EURS": "HITBTC:ZECEURS",
                                                "ZEC/BCH": "HITBTC:ZECBCH",
                                                "ZEC/LTC": "GEMINI:ZECLTC",
                                                "ZIL/BTC": "BINANCE:ZILBTC",
                                                "ZIL/ETH": "BINANCE:ZILETH",
                                                "ZIL/USDT": "BINANCE:ZILUSD",
                                                "ZIL/BUSD": "BINANCE:ZILUSD",
                                                "ZIL/USDC": "BINANCE:ZILUSD",
                                                "ZIL/TUSD": "BINANCE:ZILUSD",
                                                "ZIL/HUSD": "BINANCE:ZILUSD",
                                                "ZIL/DAI": "BINANCE:ZILUSD",
                                                "ZIL/PAX": "BINANCE:ZILUSD",
                                                "ZIL/BNB": "BINANCE:ZILBNB",
                                                "ZRX/BTC": "BINANCE:ZRXBTC",
                                                "ZRX/ETH": "BINANCE:ZRXETH",
                                                "ZRX/USDT": "BINANCE:ZRXUSD",
                                                "ZRX/BUSD": "BINANCE:ZRXUSD",
                                                "ZRX/USDC": "BINANCE:ZRXUSD",
                                                "ZRX/TUSD": "BINANCE:ZRXUSD",
                                                "ZRX/HUSD": "BINANCE:ZRXUSD",
                                                "ZRX/DAI": "BINANCE:ZRXUSD",
                                                "ZRX/PAX": "BINANCE:ZRXUSD",
                                                "ZRX/EURS": "COINBASE:ZRXEUR"
                                            })
}
