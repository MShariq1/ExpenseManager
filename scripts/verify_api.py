import urllib.request,urllib.error,json,uuid,argparse
parser=argparse.ArgumentParser(description='Creates and retains disposable database records; use only an approved test DB.')
parser.add_argument('--allow-test-writes',action='store_true',required=True)
parser.add_argument('--base-url',default='http://127.0.0.1:3001/api')
args=parser.parse_args()
base=args.base_url.rstrip('/')
def req(method,path,body=None,expected=200):
 data=json.dumps(body).encode() if body is not None else None
 r=urllib.request.Request(base+path,data=data,method=method,headers={'Content-Type':'application/json'})
 try:
  with urllib.request.urlopen(r,timeout=25) as res: status=res.status; value=json.load(res)
 except urllib.error.HTTPError as e: status=e.code; value=json.load(e)
 print(method,path.split('?')[0],status,'success=',value.get('success'))
 assert status==expected,(status,'unexpected status; body withheld')
 return value.get('data')
suffix=uuid.uuid4().hex[:12]
email=f'codex-integration-{suffix}@example.test';password=uuid.uuid4().hex
user=req('POST','/register',{'name':'Disposable Integration Test','email':email,'password':password},201)
uid=user['id'];print('test_user_id',uid)
assert req('POST','/login',{'email':email,'password':password})['id']==uid
req('POST','/login',{'email':email,'password':'incorrect-test-password'},expected=401)
req('POST','/register',{},expected=400)
req('GET','/expenses',expected=400)
assert req('GET',f'/expenses?userId={uid}')==[]
body={'userId':uid,'title':'Disposable integration expense','amount':12.34,'location':None,'expenseDate':'2026-10-26'}
expense=req('POST','/expenses',body,201);eid=expense['id'];print('test_expense_id',eid)
items=req('GET',f'/expenses?userId={uid}');assert len(items)==1;assert items[0]['expense_date']=='2026-10-26';print('amount_type',type(items[0]['amount']).__name__,'date_format YYYY-MM-DD','nullable_location',items[0]['location'] is None)
body.update(title='Disposable integration updated',amount=23.45,expenseDate='2026-10-25')
req('PUT',f'/expenses/{eid}',body)
items=req('GET',f'/expenses?userId={uid}');assert items[0]['title']==body['title'];assert items[0]['expense_date']==body['expenseDate'];assert float(items[0]['amount'])==23.45
print('All live flow assertions passed; disposable records retained, no DELETE route.')
