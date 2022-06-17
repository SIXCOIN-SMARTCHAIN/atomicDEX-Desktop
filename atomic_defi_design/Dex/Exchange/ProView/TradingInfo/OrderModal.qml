import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../../../Components"
import "../../../Constants"
import App 1.0

MultipageModal
{
    id: root

    property var details
    horizontalPadding: 60
    verticalPadding: 40

    onDetailsChanged: { if (!details) root.close() }
    onOpened:
    {
        swapProgress.updateSimulatedTime()
        swapProgress.updateCountdownTime()
    }
    onClosed: details = undefined

    MultipageModalContent
    {
        titleText: !details ? "" : details.is_swap ? qsTr("Swap Details") : qsTr("Order Details")
        title.font.pixelSize: Style.textSize2
        titleAlignment: Qt.AlignHCenter
        titleTopMargin: 10
        topMarginAfterTitle: 10
        flickMax: window.height - 450

        //Layout.preferredHeight: window.height - 100

        header: [
            // Complete image
            DefaultImage
            {
                visible: !details ? false : details.is_swap && details.order_status === "successful"
                Layout.alignment: Qt.AlignHCenter
                source: General.image_path + "exchange-trade-complete.png"
                height: 100
            },

            // Loading symbol
            DefaultBusyIndicator
            {
                visible: !details ? false :
                            details.is_swap && !["successful", "failed"].includes(details.order_status)
                running: visible && Qt.platform.os != "osx"
                Layout.alignment: Qt.AlignHCenter
                height: 100
            },

            RowLayout
            {
                Layout.topMargin: 10
                height: 70

                PairItemBadge
                {
                    source: General.coinIcon(!details ? atomic_app_primary_coin : details.base_coin)
                    ticker: details ? details.base_coin : ""
                    fullname: details ? General.coinName(details.base_coin) : ""
                    amount: details ? details.base_amount : ""
                }

                Qaterial.Icon
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    color: Dex.CurrentTheme.foregroundColor
                    icon: Qaterial.Icons.swapHorizontal
                }

                PairItemBadge
                {
                    source: General.coinIcon(!details ? atomic_app_primary_coin : details.rel_coin)
                    ticker: details ? details.rel_coin : ""
                    fullname: details ? General.coinName(details.rel_coin) : ""
                    amount: details ? details.rel_amount : ""
                }
            },

            // Status Text
            DefaultText
            {
                id: statusText
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                font.pixelSize: Style.textSizeMid1
                font.bold: true
                visible: !details ? false : details.is_swap || !details.is_maker
                text_value: !details ? "" : visible ? getStatusText(details.order_status) : ''
                height: 25
            },

            DefaultText
            {
                Layout.alignment: Qt.AlignHCenter
                visible: text_value != ""
                font.pixelSize: Style.textSizeSmall2
                text_value: !details ? "" : details.order_status === "refunding" ? swapProgress.getRefundText() : ""
                height: 25
            }
        ]

        ColumnLayout
        {
            id: details_column
            Layout.fillWidth: true
            spacing: 12

            // Maker/Taker
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("Order Type")
                text: !details ? "" : details.is_maker ? qsTr("Maker Order") : qsTr("Taker Order")
                label.font.pixelSize: 13
            }

            // Refund state
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("Refund State")
                text: !details ? "" : details.order_status === "refunding" ? qsTr("Your swap failed but the auto-refund process for your payment started already. Please wait and keep application opened until you receive your payment back") : ""
                label.font.pixelSize: 13
                visible: text !== ''
            }

            // Date
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("Date")
                text: !details ? "" : details.date
                label.font.pixelSize: 13
                visible: text !== ''
            }

            // ID
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("ID")
                text: !details ? "" : details.order_id
                label.font.pixelSize: 13
                visible: text !== ''
                copy: true
                privacy: true
            }

            // Payment ID
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: !details ? "" : details.is_maker ? qsTr("Maker Payment Sent ID") : qsTr("Maker Payment Spent ID")
                text: !details ? "" : details.maker_payment_id
                label.font.pixelSize: 12
                visible: text !== ''
                copy: true
                privacy: true
            }

            // Payment ID
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: !details ? "" : details.is_maker ? qsTr("Taker Payment Spent ID") : qsTr("Taker Payment Sent ID")
                text: !details ? "" : details.taker_payment_id
                label.font.pixelSize: 12
                visible: text !== ''
                copy: true
                privacy: true
            }

            // Error ID
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("Error ID")
                text: !details ? "" : details.order_error_state
                label.font.pixelSize: 13
                visible: text !== ''
            }

            // Error Details
            TextEditWithTitle
            {
                Layout.fillWidth: true
                title: qsTr("Error Log")
                text: !details ? "" : details.order_error_message
                label.font.pixelSize: 13
                visible: text !== ''
                copy: true
                onCopyNotificationTitle: qsTr("Error Log")
            }

            HorizontalLine
            {
                visible: swapProgress.visible
                Layout.fillWidth: true
                Layout.topMargin: 10
            }

            SwapProgress
            {
                id: swapProgress
                Layout.fillWidth: true
                visible: General.exists(details) && details.order_status !== "matching"
                details: root.details
            }
        }

        // Buttons
        footer:
        [
            Item
            {
                visible: refund_button.visible || cancel_order_button.visible
                Layout.fillWidth: true
            },

            // Recover Funds button
            DefaultButton
            {
                id: refund_button
                leftPadding: 15
                rightPadding: 15
                radius: 18
                enabled: !API.app.orders_mdl.recover_fund_busy
                visible: !details ? false :
                    details.recoverable && details.order_status !== "refunding"
                text: enabled ? qsTr("Recover Funds") : qsTr("Refunding...")
                font: DexTypo.body2
                onClicked: API.app.orders_mdl.recover_fund(details.order_id)
                Layout.preferredHeight: 50
            },

            // Cancel button
            DexAppOutlineButton
            {
                id: cancel_order_button
                visible: !details ? false : details.cancellable
                leftPadding: 15
                rightPadding: 15
                radius: 18
                text: qsTr("Cancel Order")
                font: DexTypo.body2
                onClicked: cancelOrder(details.order_id)
                Layout.preferredHeight: 50
            },

            Item { Layout.fillWidth: true },

            DexAppOutlineButton
            {
                id: explorer_button
                text: qsTr("View on Explorer")
                font: DexTypo.body2
                Layout.preferredHeight: 50
                leftPadding: 15
                rightPadding: 15
                radius: 18
                visible: !details ? false : details.maker_payment_id !== '' || details.taker_payment_id !== ''
                onClicked:
                {
                    if (!details) return

                    const maker_id = details.maker_payment_id
                    const taker_id = details.taker_payment_id

                    if (maker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.base_coin : details.rel_coin, maker_id)
                    if (taker_id !== '') General.viewTxAtExplorer(details.is_maker ? details.rel_coin : details.base_coin, taker_id)
                }
            },

            Item
            {
                visible: close_order_button.visible && explorer_button.visible
                Layout.fillWidth: true
            },

            DefaultButton
            {
                id: close_order_button
                text: qsTr("Close")
                font: DexTypo.body2
                leftPadding: 15
                rightPadding: 15
                radius: 18
                onClicked: root.close()
                Layout.preferredHeight: 50
            },

            Item
            {
                visible: close_order_button.visible || explorer_button.visible
                Layout.fillWidth: true
            }
        ]
    }
}
