(function () {
  const SUPABASE_URL = 'https://khefoadzfmbpxsxgniws.supabase.co';
  const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_9b2PJGMIsnebY-FTt5jh3A_uPFjHBfJ';
  const ADMIN_USERNAME = 'Susilowap';
  const ADMIN_EMAIL = 'susilowahyuap@gmail.com';

  if (!window.supabase?.createClient) throw new Error('Supabase client gagal dimuat. Periksa koneksi internet.');
  const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    auth: {persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}
  });

  const seed = [
    {id:'nm-001',title:'Jejak Nusantara',creator:'Nusantara Mod',category:'Adventure',platform:'PC',version:'v2.4',size:'1.2 GB',description:'Ekspansi peta tropis, misi eksplorasi, dan paket tekstur bernuansa kepulauan. Cocok untuk pemain yang ingin menjelajahi area baru dengan suasana Indonesia.',link:'https://example.com',youtube:'',image:'',rating:4.9,featured:true,active:true,clicks:128},
    {id:'nm-002',title:'Street Legends ID',creator:'Nusantara Mod',category:'Racing',platform:'PC',version:'v1.8',size:'780 MB',description:'Paket kendaraan, livery lokal, dan suasana balap malam kota Indonesia dengan pencahayaan yang sudah disesuaikan.',link:'https://example.com',youtube:'',image:'',rating:4.8,active:true,clicks:93},
    {id:'nm-003',title:'Rimba Terakhir',creator:'Nusantara Mod',category:'Survival',platform:'Android',version:'v1.2',size:'420 MB',description:'Mod survival hutan hujan dengan cuaca dinamis, crafting yang diperluas, dan tantangan eksplorasi baru.',link:'https://example.com',youtube:'',image:'',rating:4.7,active:true,clicks:76},
    {id:'nm-004',title:'Angkot Simulator+',creator:'Nusantara Mod',category:'Simulator',platform:'PC',version:'v3.1',size:'2.1 GB',description:'Rute baru, suasana terminal, radio lokal, dan peningkatan detail kendaraan untuk pengalaman berkendara yang lebih hidup.',link:'https://example.com',youtube:'',image:'',rating:4.9,active:true,clicks:164},
    {id:'nm-005',title:'Archipelago UI Pack',creator:'Nusantara Mod',category:'Utility',platform:'Multi',version:'v1.0',size:'85 MB',description:'Antarmuka bersih dengan ikon, peta mini, dan tema warna terinspirasi maritim yang tetap ringan digunakan.',link:'https://example.com',youtube:'',image:'',rating:4.6,active:true,clicks:51},
    {id:'nm-006',title:'Sawah Realism',creator:'Nusantara Mod',category:'Simulator',platform:'PC',version:'v2.0',size:'640 MB',description:'Tekstur lahan, sistem musim, dan peralatan pertanian untuk simulasi yang lebih hidup dan detail.',link:'https://example.com',youtube:'',image:'',rating:4.8,active:true,clicks:89},
    {id:'nm-007',title:'Merapi Expedition',creator:'Nusantara Mod',category:'Adventure',platform:'PC',version:'v1.4',size:'970 MB',description:'Jalur pendakian baru, siklus cuaca, dan mode foto untuk petualangan pegunungan.',link:'https://example.com',youtube:'',image:'',rating:4.7,active:true,clicks:44},
    {id:'nm-008',title:'Kota Hujan Traffic',creator:'Nusantara Mod',category:'Simulator',platform:'Android',version:'v1.1',size:'310 MB',description:'Peningkatan lalu lintas, cuaca hujan, dan pencahayaan jalan yang lebih realistis.',link:'https://example.com',youtube:'',image:'',rating:4.5,active:true,clicks:32},
    {id:'nm-009',title:'Garuda Performance',creator:'Nusantara Mod',category:'Utility',platform:'PC',version:'v2.2',size:'32 MB',description:'Preset performa ringan untuk membantu permainan berjalan lebih stabil pada perangkat menengah.',link:'https://example.com',youtube:'',image:'',rating:4.6,active:true,clicks:108}
  ];
  const defaultAds={
    home:{active:false,label:'Iklan beranda',mode:'banner',size:'728x90',image:'',url:'',code:''},
    left:{active:false,label:'Sponsor kiri',mode:'banner',size:'160x300',image:'',url:'',code:''},right:{active:false,label:'Sponsor kanan',mode:'banner',size:'160x300',image:'',url:'',code:''},detail:{active:false,label:'Iklan detail mod',mode:'banner',size:'728x90',image:'',url:'',code:''},top:{active:false,label:'Iklan atas',mode:'banner',size:'728x90',image:'',url:'',code:''},inline1:{active:false,label:'Iklan artikel 1',mode:'banner',size:'300x250',image:'',url:'',code:''},inline2:{active:false,label:'Iklan artikel 2',mode:'banner',size:'300x250',image:'',url:'',code:''},bottom:{active:false,label:'Iklan bawah',mode:'banner',size:'728x90',image:'',url:'',code:''}
  };
  const normalizeDownloadLinks=value=>(Array.isArray(value)?value:[]).map(link=>({label:String(link?.label||'').trim(),url:String(link?.url||'').trim()})).filter(link=>link.label&&/^https?:\/\//i.test(link.url)).slice(0,20);
  const fromModRow=row=>({id:row.id,title:row.title,creator:row.creator,category:row.category,platform:row.platform,version:row.version,size:row.size,description:row.description,details:row.details||'',installInstructions:row.install_instructions||'',downloadLabel:row.download_label||`File utama — ${row.title}`,link:row.download_url,downloadLinks:normalizeDownloadLinks(row.download_links),youtube:row.youtube_url,image:row.image_url,rating:row.rating,featured:row.featured,active:row.active,clicks:Number(row.clicks||0),createdAt:row.created_at,updatedAt:row.updated_at});
  const toModRow=item=>({id:item.id,title:item.title,creator:item.creator||'Nusantara Mod',category:item.category||'Lainnya',platform:item.platform||'Android',version:item.version||'-',size:item.size||'-',description:item.description||'',details:item.details||'',install_instructions:item.installInstructions||'',download_label:item.downloadLabel||`File utama — ${item.title||'Mod'}`,download_url:item.link||'',download_links:normalizeDownloadLinks(item.downloadLinks),youtube_url:item.youtube||'',image_url:item.image||'',rating:Number.isFinite(Number(item.rating))?Number(item.rating):0,featured:Boolean(item.featured),active:item.active!==false,clicks:Number(item.clicks||0)});
  const fromSubmissionRow=row=>({id:row.id,creator:row.creator,title:row.title,game:row.game,category:row.category,platform:row.platform,version:row.version,size:row.size,description:row.description,image:row.image_url,youtube:row.youtube_url,link:row.download_url,contact:row.contact,status:row.status,submittedAt:row.submitted_at,updatedAt:row.updated_at});
  const toSubmissionRow=item=>({creator:item.creator,title:item.title,game:item.game||'',category:item.category||'Lainnya',platform:item.platform||'Android',version:item.version||'-',size:item.size||'-',description:item.description,image_url:item.image||'',youtube_url:item.youtube||'',download_url:item.link||'',contact:item.contact||'',status:'pending'});
  const mergeSettings=(value={})=>({...value,ads:Object.fromEntries(Object.entries(defaultAds).map(([slot,base])=>[slot,{...base,...(value.ads?.[slot]||{})}]))});
  const raise=error=>{if(error)throw error};

  async function getMods(){const {data,error}=await client.from('mods').select('*').order('created_at',{ascending:false});raise(error);return(data||[]).map(fromModRow)}
  async function getMod(id){const {data,error}=await client.from('mods').select('*').eq('id',id).maybeSingle();raise(error);return data?fromModRow(data):null}
  async function upsertMod(item){const {data,error}=await client.from('mods').upsert(toModRow(item),{onConflict:'id'}).select().single();raise(error);return fromModRow(data)}
  async function deleteMod(id){const {error}=await client.from('mods').delete().eq('id',id);raise(error)}
  async function restoreSeed(){const {data,error}=await client.from('mods').upsert(seed.map(toModRow),{onConflict:'id'}).select();raise(error);return(data||[]).map(fromModRow)}
  async function getSubmissions(){const {data,error}=await client.from('submissions').select('*').order('submitted_at',{ascending:false});raise(error);return(data||[]).map(fromSubmissionRow)}
  async function createSubmission(item){const {error}=await client.from('submissions').insert(toSubmissionRow(item));raise(error)}
  async function updateSubmission(id,changes){const payload={};if(changes.status)payload.status=changes.status;const {error}=await client.from('submissions').update(payload).eq('id',id);raise(error)}
  async function getSettings(){const {data,error}=await client.from('settings').select('value').eq('id','global').maybeSingle();raise(error);return mergeSettings(data?.value||{})}
  async function saveSettings(value){const {error}=await client.from('settings').upsert({id:'global',value:mergeSettings(value)},{onConflict:'id'});raise(error)}
  async function getRanking(mods){
    const source=(mods||await getMods()).filter(item=>item.active!==false);
    const {data,error}=await client.from('ratings').select('mod_id,value');raise(error);
    const groups=new Map();
    (data||[]).forEach(row=>{const group=groups.get(row.mod_id)||[];group.push(Number(row.value)||0);groups.set(row.mod_id,group)});
    return source.map(item=>{const values=groups.get(item.id)||[],communityRating=values.length?values.reduce((sum,value)=>sum+value,0)/values.length:0;return{...item,communityRating,rankRating:communityRating||Number(item.rating||0),ratingCount:values.length}}).sort((a,b)=>b.rankRating-a.rankRating||Number(b.clicks||0)-Number(a.clicks||0)||b.ratingCount-a.ratingCount);
  }
  async function isAdmin(){const {data:{user}}=await client.auth.getUser();if(!user)return false;const {data,error}=await client.from('admin_users').select('user_id').eq('user_id',user.id).maybeSingle();return !error&&Boolean(data)}
  async function signIn(username,password){if(String(username).toLowerCase()!==ADMIN_USERNAME.toLowerCase())throw new Error('Username atau password salah.');const {error}=await client.auth.signInWithPassword({email:ADMIN_EMAIL,password});raise(error);if(!await isAdmin()){await client.auth.signOut();throw new Error('Akun ini bukan admin.')}}
  async function signOut(){await client.auth.signOut()}
  async function uploadImage(blob,id){const path=`mods/${id}-${Date.now()}.webp`;const {error}=await client.storage.from('mod-images').upload(path,blob,{contentType:'image/webp',upsert:false});raise(error);return client.storage.from('mod-images').getPublicUrl(path).data.publicUrl}
  async function incrementClicks(id){const {error}=await client.rpc('increment_mod_clicks',{mod_id:id});if(error)console.warn('Klik belum tercatat:',error.message)}
  function presenceId(){const key='nm-presence-id';let value=localStorage.getItem(key);if(!/^[0-9a-f-]{36}$/i.test(value||'')){value=crypto.randomUUID?crypto.randomUUID():'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,c=>{const r=Math.random()*16|0,v=c==='x'?r:(r&3|8);return v.toString(16)});localStorage.setItem(key,value)}return value}
  async function trackPresence(){try{await client.rpc('record_visitor_presence',{p_session_id:presenceId()})}catch(error){console.warn('Status pengunjung belum tercatat:',error.message)}}
  async function getRecentVisitorCount(minutes=120){const {data,error}=await client.rpc('recent_visitor_count',{window_minutes:minutes});raise(error);return Number(data||0)}
  async function getUser(){return (await client.auth.getUser()).data.user}
  async function signInGoogle(){const {error}=await client.auth.signInWithOAuth({provider:'google',options:{redirectTo:location.href}});raise(error)}
  async function signInEmail(email){const {error}=await client.auth.signInWithOtp({email,options:{emailRedirectTo:location.href}});raise(error)}
  async function getCommunity(modId){
    const [{data:ratings,error:ratingError},{data:comments,error:commentError},{data:{user}}]=await Promise.all([
      client.from('ratings').select('user_id,value').eq('mod_id',modId),
      client.from('comments').select('id,parent_id,body,created_at,user_id,profiles(display_name,avatar_url)').eq('mod_id',modId).order('created_at',{ascending:true}),
      client.auth.getUser()
    ]);
    raise(ratingError);raise(commentError);
    const values=(ratings||[]).map(x=>Number(x.value));
    return{user,average:values.length?values.reduce((a,b)=>a+b,0)/values.length:0,count:values.length,userRating:Number((ratings||[]).find(x=>x.user_id===user?.id)?.value||0),comments:comments||[]};
  }
  async function saveRating(modId,value){const user=await getUser();if(!user)throw new Error('Silakan login untuk memberi rating.');const {error}=await client.from('ratings').upsert({mod_id:modId,user_id:user.id,value},{onConflict:'mod_id,user_id'});raise(error)}
  async function addComment(modId,body,parentId=null){const user=await getUser();if(!user)throw new Error('Silakan login untuk berkomentar.');const payload={mod_id:modId,user_id:user.id,body:String(body).trim()};if(parentId)payload.parent_id=parentId;const {error}=await client.from('comments').insert(payload);raise(error)}
  async function deleteComment(id){const {error}=await client.from('comments').delete().eq('id',id);raise(error)}

  window.NMData={client,seed,adminUsername:ADMIN_USERNAME,get:getMods,getMod,upsert:upsertMod,remove:deleteMod,reset:restoreSeed,getSettings,saveSettings,getRanking,getSubmissions,createSubmission,updateSubmission,signIn,isAdmin,signOut,uploadImage,incrementClicks,trackPresence,getRecentVisitorCount,getUser,signInGoogle,signInEmail,getCommunity,saveRating,addComment,deleteComment,coverClass(cat){return'cover-'+String(cat||'utility').toLowerCase()},youtubeId(url=''){const match=String(url).match(/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/|shorts\/))([\w-]{6,})/i);return match?match[1]:''},detailUrl(id){return`detail.html?id=${encodeURIComponent(id)}`}};
  const pageName=location.pathname.split('/').pop()||'index.html';if(!['admin.html','monetization.html'].includes(pageName)){trackPresence();setInterval(trackPresence,5*60*1000);document.addEventListener('visibilitychange',()=>{if(!document.hidden)trackPresence()})}
})();
