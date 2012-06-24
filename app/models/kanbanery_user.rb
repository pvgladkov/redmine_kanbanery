class KanbaneryUser < ActiveRecord::Base
	unloadable

	#
	# по id из канбана получить пользователя редмайн
	# @param [integer] kanban_user_id
  # @return [User]
  def self.get_user( kanban_user_id )

		kuser = KanbaneryUser.find_by_kuser_id( kanban_user_id  )

		# если связи у нас нет.
		# попробуем найти по мылу через апи и занесем в таблицу связей
		#
		# запрашиваем через апи мыло юзера и ищем по мылу
		# пользователя в редмайн
		if kuser == nil

			kuser_email = KanbaneryUser::get_user_email_via_api( kanban_user_id )

      return nil unless kuser_email

			user = User.find_by_mail( kuser_email )

			# сохраним новую связь
      if user != nil
        new_kuser = KanbaneryUser.new(
          :user_id => user.id, :kuser_id => kanban_user_id
        )
        new_kuser.save()
      end

		else
			user = User.find( kuser.user_id )
		end

		return user
	end

	#
	#
  # @param [Object] kanban_user_id
  def self.get_user_email_via_api( kanban_user_id )

		api = KanbaneryAPI.new()
		kanban_users = api.get_users()

		kanban_users.each do |obj|
			if obj['id'] == kanban_user_id
				return obj['email']
			end
		end
		return nil
	end

	#
	# По id из редмайна получить пользователя канбана
	#
	def self.get_kanban_user_id( user_id )

		kuser = KanbaneryUser.find_by_user_id( user_id )
		return nil unless kuser

		return kuser.kuser_id
	end
	
end
