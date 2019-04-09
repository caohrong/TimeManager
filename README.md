# TimeManager

<img src="https://swift.org/assets/images/swift.svg" alt="Swift logo" height="70" >


## Function List

### GPS Data Export
1. Put all your GPX file to Document Folder or iCloud Folder(support later). App will  find those file(only gpx or GPX able to be detect, xml or xmz will be support later) and load all data to map. Just like [Fog of World](https://itunes.apple.com/cn/app/世界迷雾/id505367096?mt=8)

TODO LIST:
* create iCloud Folder.
* load gpx data to map.
* save all gpx data to SQLite
* check whether the data already import.(user md5 and create the table record all the file already import)
* 

### GPS Data Tracker


###  Apple Health Analytics

## Notes
### Location Format
#### WGS84坐标
World Geodetic System 1984，是为GPS全球定位系统使用而建立的坐标系统。（http://zh.wikipedia.org/wiki/WGS84）
建立WGS-84世界大地坐标系的一个重要目的，是在世界上建立一个统一的地心坐标系。
谷歌地图国外部分用的是WGS84坐标，谷歌地图中国部分用的是GCJ-02坐标。

#### GCJ-02坐标
GCJ-02是由中国国家测绘局制订的地理信息系统的坐标系统，即“国测局-2002”，江湖上俗称的“火星坐标”。
它是一种对经纬度数据的加密算法，即加入随机的偏差。国内出版的各种地图系统（包括电子形式），必须至少采用GCJ-02对地理位置进行首次加密。
中国官方要求所有在中国运行的地图服务商要加装“国家保密插件”（亦称加密插件、加偏或SM模组），以“保障国家安全”。此插件会将真实的坐标加密成虚假的坐标，且此加偏并非线性加偏，所以各地的偏移情况都会有所不同。（http://baike.baidu.com/view/4868501.htm）

### The Deviation of China Map
![](https://wuyongzheng.github.io/china-map-deviation/gmapsat.png)

#### Reference

* [The Deviation of China Map as a Regression Problem](https://wuyongzheng.github.io/china-map-deviation/paper.html)
* [Restrictions on geographic data in China](https://en.wikipedia.org/wiki/Restrictions_on_geographic_data_in_China)

* [ChinaMapDeviation](https://github.com/maxime/ChinaMapDeviation)
* [objc-borderpatrol](https://github.com/square/objc-borderpatrol)

