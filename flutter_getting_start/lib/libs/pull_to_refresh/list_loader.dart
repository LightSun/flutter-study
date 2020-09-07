

typedef OnResult = void Function(Object context, Map<String, dynamic> params, bool refresh, dynamic data);
typedef OnException = void Function(Object context, Map<String, dynamic> params, bool refresh, Exception e);
typedef ParameterInterceptor = Map Function(Map);
typedef Respository = void Function(Object context, Map<String, dynamic> params, bool refresh, OnResult result, {OnException e});

class PageManager{
   int pageNo = 0;
   int pageSize = 10;
   bool allLoadDone;

   Respository _respository;
   ParameterInterceptor _interceptor;

   PageManager(this._respository, this._interceptor);

  void request(Object context, bool refresh, OnResult result, OnException e){
     Map<String, dynamic> map = _getParameterMap(refresh);
     _respository.call(context, map, refresh, result, e: e);
   }

   Map<String, dynamic> _getParameterMap(bool refresh){
     if (refresh) {
       pageNo = 1;
       allLoadDone = false;
     } else {
       pageNo += 1;
     }
     Map<String, dynamic> map = createMap(pageNo, pageSize);
     if(_interceptor != null){
       map = _interceptor.call(map);
     }
     return map;
   }

  Map<String, dynamic> createMap(int pageNo, int pageSize) {
     return {"pageNo": pageNo, "pageSize": pageSize};
  }
}

class HttpRequestContext{
 static const int TYPE_GET = 1;
 static const int TYPE_POST_BODY = 2;
 static const int TYPE_POST_FORM = 3;

 String url;
 int type;
 Object dataType;

 HttpRequestContext(this.url, this.type, this.dataType);
}
abstract class ListDataOwner{
  List getList();
}

class ListCallback{
   bool handleRefresh(){
     return false;
   }
   List map(List data){
     return data;
   }
   List getListData(Object data){
     if(data is List){
       return data;
     }
     if(data is ListDataOwner){
        return data.getList();
     }
     throw new Exception("data should impl ListDataOwner");
   }
}
abstract class UiCallback{

  void setRequesting(bool requesting, {bool clearItems,bool resetError, bool resetEmpty});

  void markRefreshing();
  // requesting = false. refreshing = false;
  void showEmpty(dynamic data);
  // requesting = false. refreshing = false;
  void showContent(List data, FooterState state);
  // requesting = false. refreshing = false;
  void showError(Exception e, bool clearItems);
}
enum FooterState{
  STATE_NORMAL ,
  STATE_THE_END ,
  STATE_LOADING ,
  STATE_NET_ERROR
}

class ListHelper{

  ListCallback callback;
  UiCallback uiCallback;
  PageManager pageManager;
  Object context;

  void requestData(bool refresh, {bool clearData}){
    uiCallback.setRequesting(true, clearItems: refresh, resetEmpty: true, resetError: true);

    pageManager.request(context, refresh, _onResult, _onException);
  }

  void refresh(){
    if(!callback.handleRefresh()){
      uiCallback.markRefreshing();
      requestData(true);
    }
  }
  void _onResult(Object context, Map<String, dynamic> params, bool refresh, dynamic data){
    //uiCallback.setRequesting(false);
    List realData = callback.getListData(data);
    if(realData.isEmpty && pageManager.pageNo == 1){
        uiCallback.showEmpty(data);
        return;
    }
    FooterState state;
    if(realData.length < pageManager.pageSize){
      pageManager.allLoadDone = true;
      state = pageManager.pageNo == 1 ? FooterState.STATE_NORMAL : FooterState.STATE_THE_END;
    }else{
      state = FooterState.STATE_NORMAL;
    }
    uiCallback.showContent(callback.map(realData), state);
  }

  void _onException(Object context, Map<String, dynamic> params, bool refresh, Exception e){
    //
    uiCallback.showError(e, true);
  }
}