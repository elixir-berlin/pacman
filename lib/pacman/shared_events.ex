defmodule Pacman.SharedEvents do

	# NOTE: not sure we want to rebuild a mailbox
  #       might solve synchronization issues (?)

	def events_loop(events_queue // []) do
		receive do
			:quit -> Process.exit(self, :kill)			

			{:queue_event, event} ->
				# NOTE: couldn't find better push for List
				events_queue = List.flatten(events_queue, [event])
				events_loop(events_queue)

			:pop_event when length(events_queue) > 0 ->
				[event | rest] = events_queue
				send :engine, {:event, event}
				events_loop(rest)
		end
	end
end
