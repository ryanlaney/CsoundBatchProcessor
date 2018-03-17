import Cocoa

extension Int {
    func forceNumDigits(n: Int) -> String{
        let orig = Float(self)
        var ret = String(self)
        for i in (2...n).reverse(){
            if orig < pow(Float(10),Float(i-1)){
                ret = "0" + ret
            }
        }
        return ret
    }
}

func unique(array: Array<String>) -> Array<String>{
    var newArray = Array<String>()
    for i in 0..<array.count{
        var isUnique = true
        for j in (i+1)..<array.count{
            if (array[i] == array[j]){
                isUnique = false
                break
            }
        }
        if (isUnique){
            newArray.append(array[i])
        }
    }
    return newArray
}