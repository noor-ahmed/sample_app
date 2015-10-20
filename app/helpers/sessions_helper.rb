module	SessionsHelper
		#	Logs	in	the	given	user.
		def	log_in(user)
				session[:user_id]	=	user.id
		end
		
		def	current_user
				if	(user_id	=	session[:user_id])
						@current_user	||=	User.find_by(id:	user_id)
						
				elsif	(user_id	=	cookies.signed[:user_id])
								#	The	tests	still	pass,	so	this	branch	is	currently	untested.
						user	=	User.find_by(id:	user_id)
						if	user	&&	user.authenticated?(cookies[:remember_token])
								log_in	user
								@current_user	=	user
						end
				end
		end
		
		def	create
				user	=	User.find_by(email:	params[:session][:email].downcase)
				if	user	&&	user.authenticate(params[:session][:password])
						log_in	user
						params[:session][:remember_me]	==	'1'	?	remember(user)	:	forget(user)
						redirect_back_or	user
				else
						flash.now[:danger]	=	'Invalid	email/password	combination'
						render	'new'
				end
		end
		
		def	forget(user)
				user.forget
				cookies.delete(:user_id)
				cookies.delete(:remember_token)
		end
		
		def	logged_in?
				!current_user.nil?
		end
		
		def	remember(user)
				user.remember
				cookies.permanent.signed[:user_id]	=	user.id
				cookies.permanent[:remember_token]	=	user.remember_token
		end
		
		def	current_user?(user)
				user	==	current_user
		end
		
		def	log_out
				forget(current_user)
				session.delete(:user_id)
				@current_user	=	nil
		end
		
			#	Redirects	to	stored	location	(or	to	the	default).
		def	redirect_back_or(default)
				redirect_to(session[:forwarding_url]	||	default)
				session.delete(:forwarding_url)
		end
		#	Stores	the	URL	trying	to	be	accessed.
		def	store_location
				session[:forwarding_url]	=	request.url	if	request.get?
		end
		
end