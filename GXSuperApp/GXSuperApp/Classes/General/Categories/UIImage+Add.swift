//
//  UIImage+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit

extension UIImage {

    class func gx_createImage(view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
        if let cgImage = image.cgImage {
            return UIImage.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        } else {
            return UIImage()
        }
    }

    class var gx_default: UIImage? {
        return UIImage(named: "com_empty_ic_nodata")
    }
    
    class var gx_defaultName: String {
        return"com_empty_ic_nodata"
    }
    
    class var gx_defaultAvatar: UIImage? {
        return UIImage(named: "default_avatar")
    }

    class var gx_defaultActivityIcon: UIImage? {
        return UIImage(named: "a_act_default")
    }
    
    class func gx_blurImage(_ image: UIImage, radius: CGFloat = 30.0) -> UIImage {
        let context = CIContext (options:  nil )
        let  inputImage = CIImage (image: image)
        //使用高斯模糊滤镜
        let  filter  =  CIFilter (name:  "CIGaussianBlur" )!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        let  outputCIImage =  filter.outputImage!
        let  rect =  CGRect (origin:  CGPoint .zero, size: image.size)
        let  cgImage = context.createCGImage(outputCIImage, from: rect)
        //显示生成的模糊图片
        let newImage =  UIImage (cgImage: cgImage!)
        return newImage
    }

}

extension UIImage {
    //MARK: -传进去字符串,生成二维码图片
    class func createQRCodeImage(text: String, image: UIImage? = nil, completion: GXActionBlockItem<UIImage?>?) {
        DispatchQueue.global().async {
            //创建滤镜
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setDefaults()
            //将url加入二维码
            filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
            //取出生成的二维码（不清晰）
            if let outputImage = filter?.outputImage {
                //生成清晰度更好的二维码
                let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
                //如果有一个头像的话，将头像加入二维码中心
                if var image = image {
                    //给头像加一个白色圆边（如果没有这个需求直接忽略）
                    image = UIImage.circleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
                    //合成图片
                    let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 100, height: 100)

                    DispatchQueue.main.async {
                        completion?(newImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?(qrCodeImage)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }

    //image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    class func syntheticImage(_ image: UIImage, iconImage:UIImage, width: CGFloat, height: CGFloat) -> UIImage{
        //开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        //绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let x = (image.size.width - width) * 0.5
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }

    //MARK: - 生成高清的UIImage
    class func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)

        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!

        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!

        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }

    //MARK: - 生成圆形边框
    class func circleImageWithImage(_ sourceImage: UIImage, borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth

        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        UIGraphicsGetCurrentContext()

        let radius = (sourceImage.size.width < sourceImage.size.height ? sourceImage.size.width:sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth * 0.5, y: imageHeight * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    class func createRoundedImage(_ color: UIColor,
                                  size: CGSize = CGSize(width: 10, height: 10),
                                  radius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius:radius)
        context.addPath(path.cgPath)
        context.setFillColor(color.cgColor)
        context.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

}

extension UIImage {
    /// 获取图片的主题色
    func getDominantColors(count: Int, completion: @escaping ([UIColor]) -> Void) {
        DispatchQueue.global().async {
            guard let cgImage = self.cgImage else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let thumbSize = CGSize(width: 100, height: 100)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            
            guard let context = CGContext(data: nil,
                                          width: Int(thumbSize.width),
                                          height: Int(thumbSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: Int(thumbSize.width) * 4,
                                          space: colorSpace,
                                          bitmapInfo: bitmapInfo.rawValue) else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let drawRect = CGRect(x: 0, y: 0, width: thumbSize.width, height: thumbSize.height)
            context.draw(cgImage, in: drawRect)
            
            guard let data = context.data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            var colors = [UIColor]()
            for x in 0..<Int(thumbSize.width) {
                for y in 0..<Int(thumbSize.height) {
                    let offset = 4 * (x + y * Int(thumbSize.width))
                    let red = data.load(fromByteOffset: offset, as: UInt8.self)
                    let green = data.load(fromByteOffset: offset + 1, as: UInt8.self)
                    let blue = data.load(fromByteOffset: offset + 2, as: UInt8.self)
                    let alpha = data.load(fromByteOffset: offset + 3, as: UInt8.self)
                    
                    let color = UIColor(red: CGFloat(red) / 255.0,
                                        green: CGFloat(green) / 255.0,
                                        blue: CGFloat(blue) / 255.0,
                                        alpha: CGFloat(alpha) / 255.0)
                    colors.append(color)
                }
            }
            
            let kMeansColors = self.kMeans(colors, k: count)
            DispatchQueue.main.async {
                completion(kMeansColors)
            }
        }
    }
    
    private func kMeans(_ colors: [UIColor], k: Int) -> [UIColor] {
        guard !colors.isEmpty else { return [] }
        
        var centroids = Array(colors.prefix(k))
        var clusters = [[UIColor]](repeating: [], count: k)
        
        for _ in 0..<10 { // Run for a fixed number of iterations
            clusters = [[UIColor]](repeating: [], count: k)
            
            for color in colors {
                let centroidIndex = centroids.enumerated().min(by: { lhs, rhs in
                    return color.distance(to: lhs.element) < color.distance(to: rhs.element)
                })!.offset
                clusters[centroidIndex].append(color)
            }
            
            centroids = clusters.map { cluster in
                guard !cluster.isEmpty else { return UIColor.white }
                let sumComponents = cluster.reduce(into: (r: 0.0, g: 0.0, b: 0.0, a: 0.0)) { acc, color in
                    var r: CGFloat = 0
                    var g: CGFloat = 0
                    var b: CGFloat = 0
                    var a: CGFloat = 0
                    color.getRed(&r, green: &g, blue: &b, alpha: &a)
                    acc.r += Double(r)
                    acc.g += Double(g)
                    acc.b += Double(b)
                    acc.a += Double(a)
                }
                let count = CGFloat(cluster.count)
                return UIColor(red: CGFloat(sumComponents.r) / count,
                               green: CGFloat(sumComponents.g) / count,
                               blue: CGFloat(sumComponents.b) / count,
                               alpha: CGFloat(sumComponents.a) / count)
            }
        }
        
        return centroids
    }
}

private extension UIColor {
    func distance(to color: UIColor) -> CGFloat {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2) + pow(a1 - a2, 2))
    }
}
