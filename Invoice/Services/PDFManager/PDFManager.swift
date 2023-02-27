//
//  PDFManager.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import UIKit

final class PDFManager {
    
    static let shared = PDFManager()
    
    private func renderInvoice1(_ model: InvoiceModel, client: ClientModel, presenter: MainViewOutput) -> String {
        
        var html = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <style>
            @font-face {
              font-family: Arial;
            }

            .clearfix:after {
              content: "";
              display: table;
              clear: both;
            }

            a {
              color: #0087C3;
              text-decoration: none;
            }

            body {
              position: relative;
              width: 21cm;
              height: 29.7cm;
              margin: 0 auto;
               color: #555555;
              background: #FFFFFF;
              font-family: Arial, sans-serif;
              font-size: 14px;
              font-family: Arial;
            }

            header {
              padding: 10px 0;
              margin-bottom: 20px;
              border-bottom: 1px solid #AAAAAA;
            }

            #logo {
              float: left;
              margin-top: 8px;
            }

            #logo img {
              height: 70px;
            }

            #company {
              float: right;
              text-align: right;
            }

            #details {
              margin-bottom: 50px;
            }

            #client {
              padding-left: 6px;
              border-left: 6px solid #0087C3;
              float: left;
            }

            #client .to {
              color: #777777;
            }

            h2.name {
              font-size: 1.4em;
              font-weight: normal;
              margin: 0;
            }

            #invoice {
              float: right;
              text-align: right;
            }

            #invoice h1 {
              color: #0087C3;
              font-size: 2.0em;
              line-height: 1em;
              font-weight: normal;
              margin: 0  0 10px 0;
            }

            #invoice .date {
              font-size: 1.1em;
              color: #777777;
            }

            table {
              width: 100%;
              border-collapse: collapse;
              border-spacing: 0;
              margin-bottom: 20px;
            }

            table th,
            table td {
              padding: 20px;
              background: #EEEEEE;
              text-align: center;
              border-bottom: 1px solid #FFFFFF;
            }

            table th {
              white-space: nowrap;
              font-weight: normal;
            }

            table td {
              text-align: right;
            }

            table td h3{
              color: #2A82FF;
              font-size: 1.2em;
              font-weight: normal;
              margin: 0 0 0.2em 0;
            }

            table .no {
              color: #FFFFFF;
              font-size: 1.2em;
              background: #2A82FF;
            }

            table .desc {
              text-align: left;
            }

            table .unit {
            }

            table .tax {
              background: #DDDDDD;
            }

            table .qty {
              background: #DDDDDD;
            }

            table .total {
              background: #2A82FF;
              color: #FFFFFF;
            }

            table td.unit,
            table td.qty,
            table td.tax,
            table td.total {
              font-size: 1.2em;
            }

            table tbody tr:last-child td {
              border: none;
            }

            table tfoot td {
              padding: 10px 20px;
              background: #FFFFFF;
              border-bottom: none;
              font-size: 1.2em;
              white-space: nowrap;
              border-top: 1px solid #AAAAAA;
            }

            table tfoot tr:first-child td {
              border-top: none;
            }

            table tfoot tr:last-child td {
              color: #2A82FF;
              font-size: 1.4em;
              border-top: 1px solid #2A82FF;
            }

            table tfoot tr td:first-child {
              border: none;
            }

            #thanks{
              font-size: 2em;
              margin-bottom: 50px;
            }

            #notices{
              padding-left: 6px;
              border-left: 6px solid #0087C3;
            }

            #notices .notice {
              font-size: 1.2em;
            }

            footer {
              color: #777777;
              width: 100%;
              height: 30px;
              position: absolute;
              bottom: 70px;
              border-top: 1px solid #AAAAAA;
              margin-bottom: 10px;
              padding: 8px 0;
              text-align: center;
            }
            </style>
            <title>INVOICE \(model.invoiceString)</title>
          </head>
          <body>
            <header class="clearfix">
              <div id="company">
                
        """
        
        if let name = presenter.bussinessName(), !name.isEmpty {
            html += """
                <h2 class="name">\(name.trimmingCharacters(in: .whitespacesAndNewlines))</h2>
            """
        }
        
        if let number = presenter.bussinessNumber(), !number.isEmpty {
            html += """
                <div>\(number)</div>
            """
        }
        
        if let phone = presenter.bussinessPhone(), !phone.isEmpty {
            html += """
                <div>\(phone.trimmingCharacters(in: .whitespacesAndNewlines))</div>
            """
        }
        
        if let email = presenter.bussinessEmail(), !email.isEmpty {
            html += """
                <div><a href="mailto:\(email.trimmingCharacters(in: .whitespacesAndNewlines))">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>
            """
        }
        
        if let website = presenter.bussinessWebsite(), !website.isEmpty {
            html += """
                <div><a href="\(website.trimmingCharacters(in: .whitespacesAndNewlines))">\(website.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>
            """
        }
        
        if let address = presenter.bussinessAddress(), !address.isEmpty {
            html += """
                <div>\(address.trimmingCharacters(in: .whitespacesAndNewlines))</div>
            """
        }
        
        html += """
        </div>
              </div>
            </header>
            <main>
              <div id="details" class="clearfix">
                <div id="client">
                  <div class="to">BILL TO:</div>
                    <h2 class="name">\(client.name.trimmingCharacters(in: .whitespacesAndNewlines))</h2>
        """
        
        if let phone = client.phone, !phone.isEmpty {
            html += """
                <div class="address">\(phone.trimmingCharacters(in: .whitespacesAndNewlines))</div>
            """
        }
        
        if let address = client.address, !address.isEmpty {
            html += """
                <div class="address">\(address.trimmingCharacters(in: .whitespacesAndNewlines))</div>
            """
        }
        
        if let email = client.email, !email.isEmpty {
            html += """
                <div class="email"><a href="mailto:\(email.trimmingCharacters(in: .whitespacesAndNewlines))">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>
            """
        }
        
        let issueDate = presenter.stringDate(model.issueDate)
        let dueDate = presenter.stringDate(model.dueDate)
        
        html += """
            </div>
                    <div id="invoice">
                      <h1>INVOICE \(model.invoiceString)</h1>
                      <div class="date">Issue Date: \(issueDate)</div>
                      <div class="date">Due Date: \(dueDate)</div>
                    </div>
                  </div>
                  <table border="0" cellspacing="0" cellpadding="0">
                    <thead>
                      <tr>
                        <th class="no">#</th>
                        <th class="desc">DESCRIPTION</th>
                        <th class="qty">QUANTITY</th>
                        <th class="unit">UNIT PRICE</th>
                        <th class="tax">TAX</th>
                        <th class="total">TOTAL</th>
                      </tr>
                    </thead>
                    <tbody>
        """
        
        if let items = model.convertDataToItems() {
            for index in 0 ..< items.count {
                let item = items[index]
                
                html += """
                    <tr>
                    <td class="no">\(index + 1)</td>
                    <td class="desc">\(item.name)</td>
                    <td class="qty">\(item.quantity)</td>
                    <td class="unit">\(presenter.stringAmount(item.amount))</td>
                    <td class="tax">\(presenter.stringAmount(item.tax))</td>
                    <td class="total">\(presenter.stringAmount(item.total))</td>
                    </tr>
                """
            }
        }
        
        var paidText = "PAID"
        if let paidDate = model.paidDate { paidText = "PAID " + presenter.stringDate(paidDate) }
        
        html += """
            </tbody>
                    <tfoot>
                      <tr>
                        <td colspan="2"></td>
                        <td colspan="3">SUBTOTAL</td>
                        <td>\(presenter.stringAmount(model.subtotal))</td>
                      </tr>
                      <tr>
                        <td colspan="2"></td>
                        <td colspan="3">DISCOUNT</td>
                        <td>\(presenter.stringAmount(model.discount))</td>
                      </tr>
                      <tr>
                        <td colspan="2"></td>
                        <td colspan="3">TAX</td>
                        <td>\(presenter.stringAmount(model.tax))</td>
                      </tr>
                      <tr>
                        <td colspan="2"></td>
                        <td colspan="3">\(paidText)</td>
                        <td>\(presenter.stringAmount(model.balance))</td>
                      </tr>
                      <tr>
                        <td colspan="2"></td>
                        <td colspan="3">GRAND TOTAL</td>
                        <td>\(presenter.stringAmount(model.total))</td>
                      </tr>
                    </tfoot>
                  </table>
                  <div id="thanks">Thank you!</div>
        """
        
        if let notes = model.notes {
            html += """
                <div id="notices">
                    <div>NOTES:</div>
                    <div class="notice">\(notes)</div>
                </div>
            """
        }
        
        html += """
                </main>
                <footer>
                    Invoice was created in the Invoice Mobile App for iOS and is valid without the signature and seal.
                </footer>
                </body>
            </html>
        """
        
        return html
    }
    
    private func renderInvoice2(_ model: InvoiceModel, client: ClientModel, presenter: MainViewOutput) -> String {
        
        let issueDate = presenter.stringDate(model.issueDate)
        let dueDate = presenter.stringDate(model.dueDate)
        
        var html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
            <meta charset="utf-8">
            <style>
            @font-face {
              font-family: Arial;
            }

            .clearfix:after {
              content: "";
              display: table;
              clear: both;
            }

            a {
              color: #001028;
              text-decoration: none;
            }

            body {
              font-family: Arial;
              position: relative;
              width: 21cm;
              height: 29.7cm;
              margin: 0 auto;
              color: #001028;
              background: #FFFFFF;
              font-size: 14px;
            }

            .arrow {
              margin-bottom: 4px;
            }

            .arrow.back {
              text-align: right;
            }

            .inner-arrow {
              padding-right: 10px;
              height: 30px;
              display: inline-block;
              background-color: rgb(233, 125, 49);
              text-align: center;

              line-height: 30px;
              vertical-align: middle;
            }

            .arrow.back .inner-arrow {
              background-color: rgb(233, 217, 49);
              padding-right: 0;
              padding-left: 10px;
            }

            .arrow:before,
            .arrow:after {
              content:'';
              display: inline-block;
              width: 0; height: 0;
              border: 15px solid transparent;
              vertical-align: middle;
            }

            .arrow:before {
              border-top-color: rgb(233, 125, 49);
              border-bottom-color: rgb(233, 125, 49);
              border-right-color: rgb(233, 125, 49);
            }

            .arrow.back:before {
              border-top-color: transparent;
              border-bottom-color: transparent;
              border-right-color: rgb(233, 217, 49);
              border-left-color: transparent;
            }

            .arrow:after {
              border-left-color: rgb(233, 125, 49);
            }

            .arrow.back:after {
              border-left-color: rgb(233, 217, 49);
              border-top-color: rgb(233, 217, 49);
              border-bottom-color: rgb(233, 217, 49);
              border-right-color: transparent;
            }

            .arrow span {
              display: inline-block;
              width: 80px;
              margin-right: 20px;
              text-align: right;
            }

            .arrow.back span {
             margin-right: 0;
              margin-left: 20px;
              text-align: left;
            }

            h1 {
              color: #5D6975;
              font-family: Arial;
              font-size: 2.4em;
              line-height: 1.4em;
              font-weight: normal;
              text-align: center;
              border-top: 1px solid #5D6975;
              border-bottom: 1px solid #5D6975;
              margin: 0 0 2em 0;
            }

            h1 small {
              font-size: 0.45em;
              line-height: 1.5em;
              float: left;
            }

            h1 small:last-child {
              float: right;
            }

            #project {
              float: left;
            }

            #company {
              float: right;
            }

            table {
              width: 100%;
              border-collapse: collapse;
              border-spacing: 0;
              margin-bottom: 30px;
            }

            table th,
            table td {
              text-align: center;
            }

            table th {
              padding: 5px 20px;
              color: #5D6975;
              border-bottom: 1px solid #C1CED9;
              white-space: nowrap;
             font-weight: normal;
            }

            table .service,
            table .desc {
              text-align: left;
            }

            table td {
              padding: 20px;
              text-align: right;
            }

            table td.service,
            table td.desc {
              vertical-align: top;
            }

            table td.unit,
            table td.qty,
            table td.total {
              font-size: 1.2em;
            }

            table td.sub {
              border-top: 1px solid #C1CED9;
            }

            table td.grand {
              border-top: 1px solid #5D6975;
            }

            table tr:nth-child(2n-1) td {
              background: #EEEEEE;
            }

            table tr:last-child td {
              background: #DDDDDD;
            }

            #details {
              margin-bottom: 30px;
            }

            footer {
            color: #5D6975;
              width: 100%;
              height: 30px;
              position: absolute;
              bottom: 60px;
              border-top: 1px solid #C1CED9;
              margin-bottom: 10px;
              padding: 8px 0;
              text-align: center;
            }
            </style>
            <title>INVOICE \(model.invoiceString)</title>
            </head>
            <body>
            <main>
              <h1  class="clearfix"><small><span>DATE</span><br />\(issueDate)</small> INVOICE \(model.invoiceString) <small><span>DUE DATE</span><br />\(dueDate)</small></h1>
              <table>
                <thead>
                  <tr>
                    <th class="service">#</th>
                    <th class="desc">DESCRIPTION</th>
                    <th class="qty">QTY</th>
                    <th class="unit">PRICE</th>
                    <th class="unit">TAX</th>
                    <th class="total">TOTAL</th>
                  </tr>
                </thead>
                <tbody>
            """
        
        if let items = model.convertDataToItems() {
            for index in 0 ..< items.count {
                let item = items[index]
                
                html += """
                    <tr>
                    <td class="service">\(index + 1)</td>
                    <td class="desc">\(item.name)</td>
                    <td class="qty">\(item.quantity)</td>
                    <td class="unit">\(presenter.stringAmount(item.amount))</td>
                    <td class="unit">\(presenter.stringAmount(item.tax))</td>
                    <td class="total">\(presenter.stringAmount(item.total))</td>
                    </tr>
                """
            }
        }
        
        var paidText = "PAID"
        if let paidDate = model.paidDate { paidText = "PAID " + presenter.stringDate(paidDate) }
        
        html += """
            <tr>
                <td colspan="5" class="sub">SUBTOTAL</td>
                <td class="sub total">\(presenter.stringAmount(model.subtotal))</td>
            </tr>
            <tr>
                <td colspan="5" class="sub">DISCOUNT</td>
                <td class="sub total">\(presenter.stringAmount(model.discount))</td>
            </tr>
            <tr>
                <td colspan="5">TAX</td>
                <td class="total">\(presenter.stringAmount(model.tax))</td>
            </tr>
            <tr>
                <td colspan="5" class="grand total">\(paidText)</td>
                <td class="grand total">\(presenter.stringAmount(model.balance))</td>
            </tr>
            <tr>
                <td colspan="5" class="grand total">GRAND TOTAL</td>
                <td class="grand total">\(presenter.stringAmount(model.total))</td>
            </tr>
            </tbody>
            </table>
            """
        
        html += """
            <div id="details" class="clearfix">
            <div id="project">
                <div class="arrow"><div class="inner-arrow"><span>CLIENT</span>\(client.name)</div></div>
            """
                
        if let phone = client.phone, !phone.isEmpty {
            html += """
                <div class="arrow"><div class="inner-arrow"><span>PHONE</span>\(phone.trimmingCharacters(in: .whitespacesAndNewlines))</div></div>
            """
        }
        
        if let email = client.email, !email.isEmpty {
            html += """
                <div class="arrow"><div class="inner-arrow"><span>EMAIL</span><a href="mailto:\(email.trimmingCharacters(in: .whitespacesAndNewlines))">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a></div></div>
            """
        }
        
        if let address = client.address, !address.isEmpty {
            html += """
                <div class="arrow"><div class="inner-arrow"><span>ADDRESS</span>\(address.trimmingCharacters(in: .whitespacesAndNewlines))</div></div>
            """
        }
        
        html += """
            </div>
            <div id="company">
            """
        
        if let name = presenter.bussinessName(), !name.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow">\(name.trimmingCharacters(in: .whitespacesAndNewlines))<span>COMPANY</span></div></div>
            """
        }
        
        if let number = presenter.bussinessNumber(), !number.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow">\(number.trimmingCharacters(in: .whitespacesAndNewlines))<span>TAXPAYER</span></div></div>
            """
        }
        
        if let phone = presenter.bussinessPhone(), !phone.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow">\(phone.trimmingCharacters(in: .whitespacesAndNewlines))<span>PHONE</span></div></div>
            """
        }
        
        if let email = presenter.bussinessEmail(), !email.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow"><a href="mailto:\(email.trimmingCharacters(in: .whitespacesAndNewlines))">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a><span>EMAIL</span></div></div>
            """
        }
        
        if let website = presenter.bussinessWebsite(), !website.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow"><a href="\(website.trimmingCharacters(in: .whitespacesAndNewlines))">\(website.trimmingCharacters(in: .whitespacesAndNewlines))</a><span>WEBSITE</span></div></div>
            """
        }
        
        if let address = presenter.bussinessAddress(), !address.isEmpty {
            html += """
                <div class="arrow back"><div class="inner-arrow">\(address.trimmingCharacters(in: .whitespacesAndNewlines))<span>ADDRESS</span></div></div>
            """
        }
        
        html += """
            </div>
            </div>
        """
        
        if let notes = model.notes {
            html += """
                <div id="notices">
                <div>NOTES:</div>
                    <div class="notice">\(notes)</div>
                </div>
            """
        }
        
        html += """
            </main>
            <footer>
                Invoice was created in the Invoice Mobile App for iOS and is valid without the signature and seal.
            </footer>
            </body>
            </html>
        """
        
        print(html)
        return html
    }
    
    private func renderInvoice3(_ model: InvoiceModel, client: ClientModel, presenter: MainViewOutput) -> String {
        
        var html = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <style>
            .clearfix:after {
              content: "";
              display: table;
              clear: both;
            }

            a {
              color: #5D6975;
              text-decoration: underline;
            }

            body {
              position: relative;
              width: 21cm;
              height: 29.7cm;
              margin: 0 auto;
              color: #001028;
              background: #FFFFFF;
              font-family: Arial, sans-serif;
              font-size: 12px;
              font-family: Arial;
            }

            header {
              padding: 10px 0;
              margin-bottom: 30px;
            }

            #logo {
              text-align: center;
              margin-bottom: 10px;
            }

            #logo img {
              width: 90px;
            }

            h1 {
              border-top: 1px solid  #5D6975;
              border-bottom: 1px solid  #5D6975;
              color: #5D6975;
              font-size: 2.4em;
              line-height: 1.4em;
              font-weight: normal;
              text-align: center;
              margin: 0 0 20px 0;
              background: url(dimension.png);
            }

            #project {
              float: left;
            }

            #project span {
              color: #5D6975;
              text-align: right;
              width: 52px;
              margin-right: 10px;
              display: inline-block;
              font-size: 0.8em;
            }

            #company {
              float: right;
              text-align: right;
            }

            #project div,
            #company div {
              white-space: nowrap;
            }

            table {
              width: 100%;
              border-collapse: collapse;
              border-spacing: 0;
              margin-bottom: 20px;
            }

            table tr:nth-child(2n-1) td {
              background: #F5F5F5;
            }

            table th,
            table td {
              text-align: center;
            }

            table th {
              padding: 5px 20px;
              color: #5D6975;
              border-bottom: 1px solid #C1CED9;
              white-space: nowrap;
              font-weight: normal;
            }

            table .service,
            table .desc {
              text-align: left;
            }

            table td {
              padding: 20px;
              text-align: right;
            }

            table td.service,
            table td.desc {
              vertical-align: top;
            }

            table td.unit,
            table td.qty,
            table td.total {
              font-size: 1.2em;
            }

            table td.grand {
              border-top: 1px solid #5D6975;;
            }

            #notices .notice {
              color: #5D6975;
              font-size: 1.2em;
            }

            footer {
              color: #5D6975;
              width: 100%;
              height: 30px;
              position: absolute;
              bottom: 70px;
              border-top: 1px solid #C1CED9;
              margin-bottom: 10px;
              padding: 8px 0;
              text-align: center;
            }
            </style>
            <title>INVOICE \(model.invoiceString)</title>
          </head>
          <body>
            <header class="clearfix">
              <h1>INVOICE \(model.invoiceString)</h1>
              <div id="company" class="clearfix">\n
        """
        
        if let name = presenter.bussinessName(), !name.isEmpty {
            html += "<div>\(name.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
        
        if let number = presenter.bussinessNumber(), !number.isEmpty {
            html += "<div>\(number.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
        
        if let phone = presenter.bussinessPhone(), !phone.isEmpty {
            html += "<div>\(phone.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
        
        if let email = presenter.bussinessEmail(), !email.isEmpty {
            html += "<div><a href=\"mailto:\(email)\">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>"
        }
        
        if let website = presenter.bussinessWebsite(), !website.isEmpty {
            html += "<div><a href=\"\(website)\">\(website.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>"
        }
        
        if let address = presenter.bussinessAddress(), !address.isEmpty {
            html += "<div>\(address.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
                
        html += """
            </div>
            <div id="project">
            <div><span>CLIENT</span>\(client.name.trimmingCharacters(in: .whitespacesAndNewlines))</div>
        """
        
        if let email = client.email, !email.isEmpty {
            html += "<div><span>EMAIL</span> <a href=\"\(email)\">\(email.trimmingCharacters(in: .whitespacesAndNewlines))</a></div>"
        }
        
        if let phone = client.phone, !phone.isEmpty {
            html += "<div><span>PHONE</span>\(phone.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
        
        if let address = client.address, !address.isEmpty {
            html += "<div><span>ADDRESS</span>\(address.trimmingCharacters(in: .whitespacesAndNewlines))</div>"
        }
        
        html += """
            <div><span>DATE</span>\(presenter.stringDate(model.issueDate))</div>
            <div><span>DUE DATE</span>\(presenter.stringDate(model.dueDate))</div>
            </div>
            </header>
            <main>
              <table>
                <thead>
                  <tr>
                    <th class="service">#</th>
                    <th class="desc">DESCRIPTION</th>
                    <th class="qty">QTY</th>
                    <th class="unit">PRICE</th>
                    <th class="unit">TAX</th>
                    <th class="total">TOTAL</th>
                  </tr>
                </thead>
                <tbody>
        """
        
        if let items = model.convertDataToItems() {
            for index in 0 ..< items.count {
                let item = items[index]
                
                html += """
                    <tr>
                    <td class="service">\(index + 1)</td>
                    <td class="desc">\(item.name)</td>
                    <td class="qty">\(item.quantity)</td>
                    <td class="unit">\(presenter.stringAmount(item.amount))</td>
                    <td class="unit">\(presenter.stringAmount(item.tax))</td>
                    <td class="total">\(presenter.stringAmount(item.total))</td>
                    </tr>
                """
            }
        }
        
        var paidText = "PAID"
        if let paidDate = model.paidDate { paidText = "PAID " + presenter.stringDate(paidDate) }
        
        html += """
            <tr>
            <td colspan="5">SUBTOTAL</td>
            <td class="total">\(presenter.stringAmount(model.subtotal))</td>
            </tr>
            <tr>
            <td colspan="5">DISCOUNT</td>
            <td class="total">\(presenter.stringAmount(model.discount))</td>
            </tr>
            <tr>
            <td colspan="5">TAX</td>
            <td class="total">\(presenter.stringAmount(model.tax))</td>
            </tr>
            <tr>
            <td colspan="5">\(paidText)</td>
            <td class="total">\(presenter.stringAmount(model.balance))</td>
            </tr>
            <tr>
            <td colspan="5" class="grand total">GRAND TOTAL</td>
            <td class="grand total">\(presenter.stringAmount(model.total))</td>
            </tr>
            </tbody>
            </table>
        """
        
        if let notes = model.notes {
            html += """
                <div id="notices">
                <div>NOTES:</div>
                <div class="notice">\(notes)</div>
                </div>
            """
        }
        
        html += """
            </main>
            <footer>
                Invoice was created in the Invoice Mobile App for iOS and is valid without the signature and seal.
            </footer>
          </body>
        </html>
        """
        
        return html.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func exportInvoiceToPDF(_ model: InvoiceModel, client: ClientModel, presenter: MainViewOutput, template: Int = 2,
                            completion: @escaping (NSData?, URL?,String?) -> Void) {
        
        var html: String = ""
        
        switch template {
        case 1:
            html = renderInvoice1(model, client: client, presenter: presenter)
        case 2:
            html = renderInvoice2(model, client: client, presenter: presenter)
        case 3:
            html = renderInvoice3(model, client: client, presenter: presenter)
        default:
            break
        }
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: html)
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let paperRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printableRect = CGRect(x: 20, y: 20, width: 565.2, height: 811.8)
        
        render.setValue(paperRect, forKey: "paperRect")
        render.setValue(printableRect, forKey: "printableRect")
        
        if let data = drawPDFUsingPrintPageRenderer(printPageRenderer: render) {
        
            let stringURL = NSTemporaryDirectory() + model.invoiceString + ".PDF"
            let outputURL = URL(fileURLWithPath: stringURL)
                    
            guard removeFileAtURLIfExists(path: stringURL) else {
                completion(nil,nil,"Unable to delete file:\n" + stringURL)
                return
            }
            
            do {
                try data.write(to: outputURL)
                completion(data,outputURL,nil)
            } catch let error {
                completion(nil,nil,"Could not create PDF file: \(error.localizedDescription)")
            }
        } else {
            completion(nil,nil,"Unable to open and use HTML template.")
        }
    }
    
    private func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, .zero, nil)
        
        for index in 0 ..< printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            printPageRenderer.drawPage(at: index, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        return data
    }
    
    private func removeFileAtURLIfExists(path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        
        return true
    }
}
