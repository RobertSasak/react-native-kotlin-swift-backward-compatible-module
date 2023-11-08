import Foundation
import PassKit
import StripeApplePay

@objc public class KotlinSwiftBackwardCompatibleTurboModuleSwift: NSObject, ApplePayContextDelegate
{

  var confirmApplePayResolver: RCTPromiseResolveBlock? = nil

  @objc public func multiply(
    _ a: Double, b: Double, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock
  ) {
    resolve(a * b)
  }

  @objc public func pay(
    _ merchantIdentifier: String, country: String, currency: String,
    resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock
  ) {
    // Configure a payment request
    let pr = StripeAPI.paymentRequest(
      withMerchantIdentifier: merchantIdentifier, country: country,
      currency: currency)

    // You'd generally want to configure at least `.postalAddress` here.
    // We don't require anything here, as we don't want to enter an address
    // in CI.
    pr.requiredShippingContactFields = []
    pr.requiredBillingContactFields = []

    // Configure shipping methods
    let firstClassShipping = PKShippingMethod(
      label: "First Class Mail", amount: NSDecimalNumber(string: "10.99"))
    firstClassShipping.detail = "Arrives in 3-5 days"
    firstClassShipping.identifier = "firstclass"
    let rocketRidesShipping = PKShippingMethod(
      label: "Rocket Rides courier", amount: NSDecimalNumber(string: "10.99"))
    rocketRidesShipping.detail = "Arrives in 1-2 hours"
    rocketRidesShipping.identifier = "rocketrides"
    pr.shippingMethods = [
      firstClassShipping,
      rocketRidesShipping,
    ]

    // Build payment summary items
    // (You'll generally want to configure these based on the selected address and shipping method.
    pr.paymentSummaryItems = [
      PKPaymentSummaryItem(label: "A very nice computer", amount: NSDecimalNumber(string: "19.99")),
      PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(string: "10.99")),
      PKPaymentSummaryItem(label: "Stripe Computer Shop", amount: NSDecimalNumber(string: "29.99")),
    ]

    // Present the Apple Pay Context:
    //    self.confirmApplePayResolver = resolve
    let applePayContext = STPApplePayContext(paymentRequest: pr, delegate: self)
    applePayContext?.presentApplePay()
  }

  public func applePayContext(
    _ context: StripeApplePay.STPApplePayContext,
    didCreatePaymentMethod paymentMethod: StripeCore.StripeAPI.PaymentMethod,
    paymentInformation: PKPayment,
    completion: @escaping StripeApplePay.STPIntentClientSecretCompletionBlock
  ) {
    confirmApplePayResolver!(1000)
  }

  public func applePayContext(
    _ context: StripeApplePay.STPApplePayContext,
    didCompleteWith status: StripeApplePay.STPApplePayContext.PaymentStatus, error: Error?
  ) {
    confirmApplePayResolver!(2000)
  }
}

//     func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
//         // When the Apple Pay sheet is confirmed, create a PaymentIntent on your backend from the provided PKPayment information.
//         BackendModel.shared.fetchPaymentIntent { secret in
//           if let clientSecret = secret {
//             // Call the completion block with the PaymentIntent's client secret.
//             completion(clientSecret, nil)
//           } else {
//             completion(nil, NSError())  // swiftlint:disable:this discouraged_direct_init
//           }
//         }
//     }

//     func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPApplePayContext.PaymentStatus, error: Error?) {
//         // When the payment is complete, display the status.
//         self.paymentStatus = status
//         self.lastPaymentError = error
//     }
// }
