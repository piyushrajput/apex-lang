/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
global class IObjectPaginator {

	global static final Integer DEFAULT_PAGE_SIZE = 20;

	private List<IObjectPaginatorListener> listeners = new List<IObjectPaginatorListener>();
	
	global List<IObject> all {get;private set;}
	global List<IObject> page {get;private set;}
	global Integer pageSize = DEFAULT_PAGE_SIZE;
	global Integer pageNumber {get;private set;}
	global Integer pageCount { get{ Double allSize = this.all == null ? 0 : this.all.size(); Double pageSize = this.pageSize; return this.all == null ? 0 : Math.ceil(allSize/pageSize).intValue(); } }
	global Integer recordCount {get{ return this.all == null ? 0 : this.all.size(); } }
	global Boolean hasNext{get{ return pageNumber >= 0 && pageNumber < this.pageCount-1;}}
	global Boolean hasPrevious{get{return pageNumber > 0 && pageNumber <= this.pageCount-1;}}

	global IObjectPaginator(List<IObject> all){
		this(all,DEFAULT_PAGE_SIZE,null);
	}
	
	global IObjectPaginator(List<IObject> all, Integer pageSize){
		this(all,pageSize,null);
	}
	
	global IObjectPaginator(List<IObject> all, Integer pageSize, IObjectPaginatorListener listener){
		addListener(listener);
		reset(all,pageSize);
	}
	
	global void setRecords(List<IObject> all){
		reset(all,this.pageSize);
	}
	
	global void setPageSize(Integer pageSize){
		reset(this.all,pageSize);
	}
	
	global PageReference skipToPage(Integer pageNumber){
		if(pageNumber < 0 || pageNumber > this.pageCount-1){
			throw new IllegalArgumentException();
		}
		this.pageNumber = pageNumber;
		updatePage();
		return null;
	}
	
	global PageReference next(){
		if(!this.hasNext){
			throw new IllegalStateException();
		}
		pageNumber++;
		updatePage();
		return null;
	}
	
	global PageReference previous(){
		if(!this.hasPrevious){
			throw new IllegalStateException();
		}
		pageNumber--;
		updatePage();
		return null;
	}
	
	global PageReference first(){
		pageNumber = 0;
		updatePage();
		return null;
	}
	
	global PageReference last(){
		pageNumber = pageCount - 1;
		updatePage();
		return null;
	}
	
	private void reset(List<IObject> all, Integer pageSize){
		this.all = all;
		this.pageSize = pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
		this.pageNumber = 0;
		updatePage();
	}

	private void updatePage() {
		this.page = null;
		if(this.all != null && this.all.size() > 0){
			Integer startPosition = this.pageNumber * this.pageSize;
			Integer endPosition = (this.pageNumber + 1) * this.pageSize - 1;
			endPosition = endPosition < this.all.size() ? endPosition : this.all.size()-1;
			this.page = new List<IObject>();
			for (Integer i = startPosition; i <= endPosition; i++) {
				this.page.add(this.all.get(i));
			}
		}
		for(IObjectPaginatorListener listener : listeners){
			listener.handlePageChange(this.page);
		}
		/*
		System.debug('==============================================================');
		System.debug('After Update Page:');
		System.debug('this.all         = ' + ArrayUtils.toString(this.all));
		System.debug('this.page        = ' + ArrayUtils.toString(this.page));
		System.debug('this.pageSize    = ' + this.pageSize);
		System.debug('this.pageNumber  = ' + this.pageNumber);
		System.debug('this.pageCount   = ' + this.pageCount);
		System.debug('this.recordCount = ' + this.recordCount);
		System.debug('this.hasNext     = ' + this.hasNext);
		System.debug('this.hasPrevious = ' + this.hasPrevious);
		System.debug('==============================================================');
		*/
	}
	
	global void addListener(IObjectPaginatorListener listener){
		if(listener != null){
			listeners.add(listener);
		}
	}

}