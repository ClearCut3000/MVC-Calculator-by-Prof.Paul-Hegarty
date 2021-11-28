//
//  Formatter.swift
//  MVC Calculator by Prof.Paul Hegarty
//
//  Created by Николай Никитин on 29.11.2021.
//

import Foundation

let formatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = 6
  formatter.notANumberSymbol = "Error"
  formatter.groupingSeparator = " "
  formatter.locale = Locale.current
  return formatter
}()
