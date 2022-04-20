class Github::ReposController < ApplicationController
   
    def index
        client = Octokit::Client.new
        
        if search_params[:query].present?
            @repos = client.search_repos(search_params[:query], per_page: search_params[:per_page], page: search_params[:page])
        end
    end



    private

    def search_params
        params.permit(:query, :per_page, :page)
    end
end