proc(_pmc_bump){
	@username = 'Dustin.a.Mundy@gmail.com'
	@password = 'xxxxxxxxxxxx'
	@serverid = '1687392'
	@userid = '486607'
   
	@cookiejar = array()
   
	msg('PlanetMineCraft Bumper: Attempting to log in and bump.')
	http_request('http://www.planetminecraft.com/forums/ucp.php?mode=login_from_main',associative_array(
		'method':'POST',
		'headers':associative_array(
			'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:19.0) Gecko/20100101 Firefox/19.0',
			'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'Accept-Language':'en,fr;q=0.7,en-us;q=0.3',
			'Referer':'http://www.planetminecraft.com/account/sign_in/'
		),
		'params':associative_array(
			'username':@username,
			'password':@password,
			'login':'Sign+In',
			'autologin':1,
			'from_main_site':1
		),
		'cookiejar':@cookiejar,
		'timeout':6000,
		'success':closure(@response,
			export('PMCBumper.LastBump.1',@response)
			if(reg_count('You have specified an incorrect password.',@response['body'])){
				msg('PMCBumper: Credentials didn\'t work.')
			}else{
				msg('PMCBumper: Successfully logged in!')
				export('AR.Cookies',@cookiejar)
				/*array_push(@cookiejar, associative_array(
					'domain':'www.planetminecraft.com',
					'name':'pmc_cookie',
					'value':'dustin.a.mundy%40gmail.com-%7C-%24H%249rU8Z3AVjaf.wLTuBT62tGeYA3Uokf1',
					'path':'/',
					'expiration':time() + 1000 * 60 * 30,
					'httpOnly':false,
					'secureOnly':false
				))*/
				http_request('http://www.planetminecraft.com/qajax.php?resource_id='.@serverid.'&member_id='.@userid.'&action=bump',associative_array(
					'method':'POST',
					'headers':associative_array(
						'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:19.0) Gecko/20100101 Firefox/19.0',
						'DNT':1,
						'X-Requested-With':'XMLHttpRequest',
						'Referer':'http://www.planetminecraft.com/account/manage/servers/'.@serverid.'/'
					),
					'cookiejar':@cookiejar,
					'timeout':6000,
					'success':closure(@response,
						export('PMCBumper.LastBump.2',@response)
						if(reg_count('You must be logged in to bump your submission.',@response['body'])){
							msg('PMCBumper: Credentials worked but you were not signed in when the bump occured.')
						}else if(reg_count('You updated or bumped this submission within the past 24 hours.',@response['body'])){
							msg('PMCBumper: You tried to bump too quickly!')
						}else{
							@message = colorize(yml_decode(read('../PMCBump.yml'))['Bump Message']['message'])
							if(yml_decode(read('../PMCBump.yml'))['Bump Message']['warn']['broadcast']){
								broadcast(@message)
							}else{
								if(yml_decode(read('../PMCBump.yml'))['Bump Message']['warn']['staff']){
									foreach(all_players(), @player){
										if(has_permission(@player, yml_decode(read('../PMCBump.yml'))['Options']['staff perm node'])){
											tmsg(@player,@message)
										}
									}
								}
								if(yml_decode(read('../PMCBump.yml'))['Bump Message']['warn']['console']){
									sys_out(@message)
								}
							}
						}
					)
				))
			}
		)
	))
}
