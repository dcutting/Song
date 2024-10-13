//
//  FakeBundle.swift
//
//  Generated by FakeBundle
//  See https://github.com/zweigraf/FakeBundle
//

import Foundation

protocol FileType {
    var isDirectory: Bool { get }
    var filename: String { get }
    func export(to path: String) throws
}
protocol File: FileType {
    var contentsBase64: String { get }
}
extension File {
    var isDirectory: Bool {
        return false
    }
    var contents: Data? {
        return Data(base64Encoded: contentsBase64)
    }

    func export(to path: String) throws {
        guard let contents = contents else { return }
        let originalUrl = URL(fileURLWithPath: path)
        let myUrl = originalUrl.appendingPathComponent(filename)
        try contents.write(to: myUrl)
    }
}
protocol Directory: FileType {
    var children: [FileType] { get }
}
extension Directory {
    var isDirectory: Bool {
        return true
    }
    func export(to path: String) throws {
        let originalUrl = URL(fileURLWithPath: path)
        let myUrl = originalUrl.appendingPathComponent(filename)
        try FileManager.default.createDirectory(at: myUrl, withIntermediateDirectories: true, attributes: nil)
        try children.forEach { try $0.export(to: myUrl.path) }
    }
}
class Stdlib: Directory {
    var filename: String = "StdLib"
    lazy var children: [FileType] = {
        return [Math_Sg(), String_Sg(), List_Sg()]
    }()

    class Math_Sg: File {
    var filename: String = "math.sg"
    lazy var contentsBase64: String = {
        return "cGkgPSAzLjE0MTU5MjY1MzU4OTc5MzIzODQKZSA9IDIuNzE4MjgxODI4NDU5MDQ1MjM1Mwp0YXUgPSA2LjI4MzE4NTMwNzE3OTU4NjQ3NjkKCm4uemVybz8gPSBuIEVxIDAKbi5ub25aZXJvPyA9IG4gTmVxIDAKbi5wb3NpdGl2ZT8gPSBuID4gMApuLm5lZ2F0aXZlPyA9IG4gPCAwCm4ubm9uTmVnYXRpdmU/ID0gTm90IG4ubmVnYXRpdmU/CgpuLnNxcnQgPSBuXjAuNQpuLnBvd2VyKGUpID0gbl5lCgpuLnNxdWFyZWQgPSBuLnBvd2VyKDIpCm4uY3ViZWQgPSBuLnBvd2VyKDMpCgpuLmV2ZW4/ID0gKG4gTW9kIDIpLnplcm8/Cm4ub2RkPyA9IChuIC0gMSkuZXZlbj8KCnguZGl2aWRlcz8oeSkgPSAoeSBNb2QgeCkuemVybz8Kbi5iZXR3ZWVuPyh4LCB5KSA9IHggPD0gbiBBbmQgbiA8PSB5CgpuLmZhY3RvcmlhbCA9IG4uZmFjdG9yaWFsKDEpCjAuZmFjdG9yaWFsKGFjYykgPSBhY2MKbi5mYWN0b3JpYWwoYWNjKSBXaGVuIG4gPiAwID0gKG4gLSAxKS5mYWN0b3JpYWwoYWNjICogbikKCmxpc3QubWF4ID0gbGlzdC5zb3J0Lmxhc3QKbGlzdC5taW4gPSBsaXN0LnNvcnQuZmlyc3QKbGlzdC5zdW0gPSBsaXN0LmluamVjdCgwLCB8YSwgeHwgYSArIHgpCgp4LnRpbWVzKG4pID0geC50aW1lcyhuLCBbXSkKMC50aW1lcyhuLCByZXN1bHQpID0gcmVzdWx0CngudGltZXMobiwgcmVzdWx0KSBXaGVuIHggPiAwID0gKHgtMSkudGltZXMobiwgcmVzdWx0ICsgW25dKQoKeC51cFRvQW5kSW5jbHVkaW5nKHgpID0gW3hdCngudXBUb0FuZEluY2x1ZGluZyh5KSBXaGVuIHggPCB5ID0gW3h8KHgrMSkudXBUb0FuZEluY2x1ZGluZyh5KV0KCngudXBUbyh4KSA9IFtdCngudXBUbyh5KSBXaGVuIHggPCB5ID0gW3h8KHgrMSkudXBUbyh5KV0KCmxpc3QubWVhbiA9IGxpc3Quc3VtIC8gbGlzdC5jb3VudApsaXN0Lm1lZGlhbiA9IGxpc3Quc29ydC5taWRkbGUKYXZlcmFnZSA9IG1lYW4K"
    }()
}


class String_Sg: File {
    var filename: String = "string.sg"
    lazy var contentsBase64: String = {
        return "c3RyLnNwbGl0KCkgPSBzdHIuc3BsaXQoIiAiKQpzdHIuc3BsaXQoZGVsaW1pdGVyKSA9IHN0ci5zcGxpdChkZWxpbWl0ZXIsIFtdLCAiIikKIiIuc3BsaXQoXywgd29yZHMsIHdvcmQpID0gd29yZHMgKyBbd29yZF0Kc3RyLnNwbGl0KGRlbGltaXRlciwgd29yZHMsIHdvcmQpIFdoZW4gc3RyLnN0YXJ0c1dpdGg/KGRlbGltaXRlcikgPSBzdHIuZHJvcChkZWxpbWl0ZXIubGVuZ3RoKS5zcGxpdChkZWxpbWl0ZXIsIHdvcmRzICsgW3dvcmRdLCAiIikKc3RyLnNwbGl0KGRlbGltaXRlciwgd29yZHMsIHdvcmQpID0gc3RyLnRhaWwuc3BsaXQoZGVsaW1pdGVyLCB3b3Jkcywgd29yZCArIFtzdHIuaGVhZF0pCgojIEVnICIiLnN0cmlwTGVhZGluZyA9ICIiCiMgRWcgIiAiLnN0cmlwTGVhZGluZyA9ICIiCiMgRWcgIiBoZWxsbyIuc3RyaXBMZWFkaW5nID0gImhlbGxvIgpbJyAnfHhzXS5zdHJpcExlYWRpbmcgPSB4cy5zdHJpcExlYWRpbmcKc3RyaW5nLnN0cmlwTGVhZGluZyA9IHN0cmluZwpzdHJpbmcuc3RyaXBUcmFpbGluZyA9IHN0cmluZy5yZXZlcnNlLnN0cmlwTGVhZGluZy5yZXZlcnNlCnN0cmluZy5zdHJpcCA9IHN0cmluZy5zdHJpcExlYWRpbmcuc3RyaXBUcmFpbGluZwoKam9pbkJvdGgoYSwgYikgPSBbYSwgYl0uam9pbgpsaXN0LmpvaW4gPSBsaXN0LmpvaW4oIiIpCltdLmpvaW4oZGVsaW1pdGVyKSA9ICIiClt4XS5qb2luKGRlbGltaXRlcikgPSB4LnN0cmluZwpbeHx4c10uam9pbihkZWxpbWl0ZXIpID0geC5zdHJpbmcgKyBkZWxpbWl0ZXIgKyB4cy5qb2luKGRlbGltaXRlcikKCmNoYXIubGV0dGVyPyA9IGNoYXIubG93ZXIuc2NhbGFyLmJldHdlZW4/KCdhJy5zY2FsYXIsICd6Jy5zY2FsYXIpCgpfYXNjaWlDYXNlRGlmZiA9ICdhJy5zY2FsYXIgLSAnQScuc2NhbGFyCgpbeHx4c10ubG93ZXIgPSBbeHx4c10ubWFwKGxvd2VyKQpbeHx4c10udXBwZXIgPSBbeHx4c10ubWFwKHVwcGVyKQoKY2hhci5sb3dlciBXaGVuIGNoYXIuc2NhbGFyLmJldHdlZW4/KCdBJy5zY2FsYXIsICdaJy5zY2FsYXIpID0gKGNoYXIuc2NhbGFyICsgX2FzY2lpQ2FzZURpZmYpLmNoYXJhY3RlcgpjaGFyLmxvd2VyID0gY2hhcgoKY2hhci51cHBlciBXaGVuIGNoYXIuc2NhbGFyLmJldHdlZW4/KCdhJy5zY2FsYXIsICd6Jy5zY2FsYXIpID0gKGNoYXIuc2NhbGFyIC0gX2FzY2lpQ2FzZURpZmYpLmNoYXJhY3RlcgpjaGFyLnVwcGVyID0gY2hhcgo="
    }()
}


class List_Sg: File {
    var filename: String = "list.sg"
    lazy var contentsBase64: String = {
        return "W10uY291bnQgPSAwCltffHhzXS5jb3VudCA9IDEgKyB4cy5jb3VudApsZW5ndGggPSBjb3VudAoKbGlzdC5lbXB0eT8gPSBsaXN0LmNvdW50IEVxIDAKClt4fF9dLmhlYWQgPSB4CltffHhzXS50YWlsID0geHMKbGlzdC5maXJzdCA9IGxpc3QuaGVhZApsaXN0LmZpcnN0KG4pID0gbGlzdC50YWtlKG4pCmxpc3Quc2Vjb25kID0gbGlzdC50YWlsLmZpcnN0Cmxpc3QudGhpcmQgPSBsaXN0LnRhaWwuc2Vjb25kCmxpc3QubGFzdCA9IGxpc3QucmV2ZXJzZS5maXJzdApsaXN0Lmxhc3QobikgPSBsaXN0LnJldmVyc2UudGFrZShuKS5yZXZlcnNlCgpbeHxfXS5hdCgwKSA9IHgKW198eHNdLmF0KGspIFdoZW4gayA+IDAgPSB4cy5hdChrLTEpCmxpc3QuYXQoaykgV2hlbiBrIDwgMCA9IGxpc3QucmV2ZXJzZS5hdCgtMS1rKQoKbGlzdC5taWRkbGUgPSBsaXN0LmF0KGxpc3QuY291bnQgRGl2IDIpCgpsaXN0LmRyb3AoMCkgPSBsaXN0CltffHhzXS5kcm9wKG4pIFdoZW4gbiA+IDAgPSB4cy5kcm9wKG4tMSkKCltdLmRyb3BXaGlsZShmKSA9IFtdClt4fHhzXS5kcm9wV2hpbGUoZikgV2hlbiB4LmYgPSB4cy5kcm9wV2hpbGUoZikKbGlzdC5kcm9wV2hpbGUoXykgPSBsaXN0CgpfLnRha2UoMCkgPSBbXQpbXS50YWtlKF8pID0gW10KW3h8eHNdLnRha2UobikgV2hlbiBuID4gMCA9IFt4XSArIHhzLnRha2Uobi0xKQoKW10udGFrZVdoaWxlKF8pID0gW10KW3h8eHNdLnRha2VXaGlsZShmKSBXaGVuIHguZiA9IFt4XSArIHhzLnRha2VXaGlsZShmKQpfLnRha2VXaGlsZShfKSA9IFtdCgpsaXN0LnNsaWNlKGksIG4pID0gbGlzdC5kcm9wKGkpLnRha2UobikKc3Vic3RyaW5nID0gc2xpY2UKCltdLmluY2x1ZGVzPyhfKSA9IE5vClt4fHhzXS5pbmNsdWRlcz8oYSkgPSBhIEVxIHggT3IgeHMuaW5jbHVkZXM/KGEpCgpbXS5yZXZlcnNlID0gW10KW3h8eHNdLnJldmVyc2UgPSB4cy5yZXZlcnNlICsgW3hdCgpsaXN0LnB1c2goeCkgPSBsaXN0ICsgW3hdCmxpc3QucG9wID0gbGlzdC5wb3AoMSkKbGlzdC5wb3AobikgPSBsaXN0LnJldmVyc2UuZHJvcChuKS5yZXZlcnNlCgpbXS5tYXAoXykgPSBbXQpbeHx4c10ubWFwKGYpID0gW2YoeCl8eHMubWFwKGYpXQoKZWFjaCA9IG1hcAoKW10uaW5qZWN0KGFjYywgXykgPSBhY2MKW3h8eHNdLmluamVjdChhY2MsIGYpID0geHMuaW5qZWN0KGFjYy5mKHgpLCBmKQoKcmVkdWNlID0gaW5qZWN0CgpbXS5zZWxlY3QoXykgPSBbXQpbeHx4c10uc2VsZWN0KGYpIFdoZW4geC5mID0gW3hdICsgeHMuc2VsZWN0KGYpCltffHhzXS5zZWxlY3QoZikgPSB4cy5zZWxlY3QoZikKCmxpc3QucmVqZWN0KGYpID0gbGlzdC5zZWxlY3QofHh8IE5vdCB4LmYpCgpsaXN0LmFwcGVuZChlKSA9IFtlfGxpc3QucmV2ZXJzZV0ucmV2ZXJzZQpsaXN0LnJlbW92ZShlKSA9IGxpc3QucmVqZWN0KHx4fCB4IEVxIGUpCgpbXS5zb3J0ID0gW10KW3h8eHNdLnNvcnQgPSB4cy5zZWxlY3QofGt8IGsgPCB4KS5zb3J0ICsgW3hdICsgeHMuc2VsZWN0KHxrfCBrID49IHgpLnNvcnQKCltdLnNvcnRCeShfKSA9IFtdCmxpc3Quc29ydEJ5KGYpID0gbGlzdC5tYXAofHh8IFt4LmYsIHhdKS5zb3J0TWFwcGVkLm1hcCh8W18sIHhdfCB4KQpbXS5zb3J0TWFwcGVkID0gW10KW1t4bSwgeF18eHNdLnNvcnRNYXBwZWQgPSBEbwogIGxlZnQgPSB4cy5zZWxlY3QofFt5bSwgeV18IHltIDwgeG0pLnNvcnRNYXBwZWQKICByaWdodCA9IHhzLnNlbGVjdCh8W3ltLCB5XXwgeW0gPj0geG0pLnNvcnRNYXBwZWQKICBsZWZ0ICsgW1t4bSwgeF1dICsgcmlnaHQKRW5kCgpbXS5mbGF0dGVuID0gW10KW1t4fHhzXXx5c10uZmxhdHRlbiA9IChbeF0gKyB4cykuZmxhdHRlbiArIHlzLmZsYXR0ZW4KW3h8eHNdLmZsYXR0ZW4gPSBbeF0gKyB4cy5mbGF0dGVuCgpbXS5hbGw/KF8pID0gWWVzClt4fHhzXS5hbGw/KGYpID0gZih4KSBBbmQgeHMuYWxsPyhmKQoKW10uYW55PyhfKSA9IE5vClt4fHhzXS5hbnk/KGYpID0gZih4KSBPciB4cy5hbnk/KGYpCgpsaXN0Lm5vbmU/KGYpID0gbGlzdC5zZWxlY3QoZikuZW1wdHk/CgpsaXN0Lm9uZT8oZikgPSBsaXN0LnNlbGVjdChmKS5jb3VudCBFcSAxCgpbXS5kZXRlY3QoXykgPSBObwpbeHxfXS5kZXRlY3QoZikgV2hlbiBmKHgpID0geApbX3x4c10uZGV0ZWN0KGYpID0geHMuZGV0ZWN0KGYpCmZpbmQgPSBkZXRlY3QKCmxpc3QuaW5kZXgoaykgPSBsaXN0LmluZGV4KGssIDApCltdLmluZGV4KF8sIF8pID0gTm8KW3h8X10uaW5kZXgoaywgaSkgV2hlbiB4IEVxIGsgPSBpCltffHhzXS5pbmRleChrLCBpKSA9IHhzLmluZGV4KGssIGkrMSkKCmxpc3QucGFydGl0aW9uKGYpID0gbGlzdC5wYXJ0aXRpb24oZiwgW10sIFtdKQpbXS5wYXJ0aXRpb24oXywgc2VsZWN0ZWQsIHJlc3QpID0gW3NlbGVjdGVkLCByZXN0XQpbeHx4c10ucGFydGl0aW9uKGYsIHNlbGVjdGVkLCByZXN0KSBXaGVuIGYoeCkgPSB4cy5wYXJ0aXRpb24oZiwgc2VsZWN0ZWQgKyBbeF0sIHJlc3QpClt4fHhzXS5wYXJ0aXRpb24oZiwgc2VsZWN0ZWQsIHJlc3QpID0geHMucGFydGl0aW9uKGYsIHNlbGVjdGVkLCByZXN0ICsgW3hdKQoKYS56aXAoYikgPSBbYSwgYl0uemlwCgpbYSwgYl0uemlwID0gW2EsIGJdLnppcFdpdGgofHgsIHl8IFt4LCB5XSkKCltbXSwgW11dLnppcFdpdGgoXykgPSBbXQpbW3h8eHNdLCBbXV0uemlwV2l0aChmKSA9IFt4XSArIFt4cywgW11dLnppcFdpdGgoZikKW1tdLCBbeXx5c11dLnppcFdpdGgoZikgPSBbeV0gKyBbW10sIHlzXS56aXBXaXRoKGYpCltbeHx4c10sIFt5fHlzXV0uemlwV2l0aChmKSA9IFtmKHgsIHkpXSArIFt4cywgeXNdLnppcFdpdGgoZikKCmxpc3QucGFsaW5kcm9tZT8gPSBsaXN0IEVxIGxpc3QucmV2ZXJzZQoKbGlzdC5sb29zZVBhbGluZHJvbWU/ID0gbGlzdC5zZWxlY3QobGV0dGVyPykubG93ZXIucGFsaW5kcm9tZT8KCl8uc3RhcnRzV2l0aD8oW10pID0gWWVzClt4fHhzXS5zdGFydHNXaXRoPyhbeHxwc10pID0geHMuc3RhcnRzV2l0aD8ocHMpCl8uc3RhcnRzV2l0aD8oXykgPSBObwoKbGlzdC5lbmRzV2l0aD8oc3VmZml4KSA9IGxpc3QucmV2ZXJzZS5zdGFydHNXaXRoPyhzdWZmaXgucmV2ZXJzZSkKCltdLmVudW1lcmF0ZSA9IFtdCmxpc3QuZW51bWVyYXRlID0gbGlzdC56aXAoMC51cFRvKGxpc3QuY291bnQpKQoKW10udW5pcXVlKHNldCkgPSBzZXQKW2V8dGFpbF0udW5pcXVlKHNldCkgV2hlbiBzZXQuaW5jbHVkZXM/KGUpID0gdGFpbC51bmlxdWUoc2V0KQpbZXx0YWlsXS51bmlxdWUoc2V0KSA9IHRhaWwudW5pcXVlKHNldCArIFtlXSkKbGlzdC51bmlxdWUgPSBsaXN0LnVuaXF1ZShlbXB0eVNldCkKCiMgRGljdGlvbmFyeQoKW10ubG9va3VwKF8pID0gTm8KW1trZXksIHZhbHVlXXx0YWlsXS5sb29rdXAoa2V5KSA9IHZhbHVlCltffHRhaWxdLmxvb2t1cChrZXkpID0gdGFpbC5sb29rdXAoa2V5KQpbXS5pbnNlcnQoa2V5LCB2YWx1ZSkgPSBbW2tleSwgdmFsdWVdXQpbW2tleSwgdmFsdWVdfHRhaWxdLmluc2VydChrZXksIG5ld1ZhbHVlKSA9IFtba2V5LCBuZXdWYWx1ZV18dGFpbF0KW2V8dGFpbF0uaW5zZXJ0KGtleSwgdmFsdWUpID0gW2V8dGFpbC5pbnNlcnQoa2V5LCB2YWx1ZSldCmVtcHR5RGljdCA9IFtdCgojIFNldAoKW10uaW5zZXJ0KHZhbHVlKSA9IFt2YWx1ZV0KW2V8dGFpbF0uaW5zZXJ0KGUpID0gW2V8dGFpbF0KW2V8dGFpbF0uaW5zZXJ0KG5ldykgPSBbZXx0YWlsLmluc2VydChuZXcpXQplbXB0eVNldCA9IFtdCg=="
    }()
}

}
