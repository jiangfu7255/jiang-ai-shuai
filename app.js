App({
  globalData: {
    userInfo: null,
    hasLogin: false,
    openid: null,
    rentOrder: null,
    swapSub: null
  },

  onLaunch: function() {
    // 确保从 storage 恢复所有数据
    var userInfo = wx.getStorageSync('userInfo');
    var hasLogin = wx.getStorageSync('hasLogin');
    var openid = wx.getStorageSync('openid');
    var rentOrder = wx.getStorageSync('rentOrder');
    var swapSub = wx.getStorageSync('swapSub');

    if (userInfo && hasLogin) {
      this.globalData.userInfo = userInfo;
      this.globalData.hasLogin = true;
      this.globalData.openid = openid;
    }
    if (rentOrder) {
      this.globalData.rentOrder = rentOrder;
    }
    if (swapSub) {
      this.globalData.swapSub = swapSub;
    }
  },

  setUserInfo: function(userInfo, openid) {
    this.globalData.userInfo = userInfo;
    this.globalData.openid = openid;
    this.globalData.hasLogin = true;
    wx.setStorageSync('userInfo', userInfo);
    wx.setStorageSync('openid', openid);
    wx.setStorageSync('hasLogin', true);
  },

  setRentOrder: function(order) {
    this.globalData.rentOrder = order;
    if (order) {
      wx.setStorageSync('rentOrder', order);
    }
  },

  setSwapSub: function(sub) {
    this.globalData.swapSub = sub;
    wx.setStorageSync('swapSub', sub);
  }
});
