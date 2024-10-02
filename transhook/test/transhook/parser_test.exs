defmodule Transhook.ParserTest do
  use Transhook.ServiceCase

  test "parse json" do
    json_params =
      ~S"""
      {
        "object_kind": "issue",
        "event_type": "issue",
        "user": {
          "id": 1,
          "name": "Administrator",
          "username": "root",
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon",
          "email": "admin@example.com"
        },
        "project": {
          "id": 1,
          "name":"Gitlab Test",
          "description":"Aut reprehenderit ut est.",
          "web_url":"http://example.com/gitlabhq/gitlab-test",
          "avatar_url":null,
          "git_ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
          "git_http_url":"http://example.com/gitlabhq/gitlab-test.git",
          "namespace":"GitlabHQ",
          "visibility_level":20,
          "path_with_namespace":"gitlabhq/gitlab-test",
          "default_branch":"master",
          "ci_config_path": null,
          "homepage":"http://example.com/gitlabhq/gitlab-test",
          "url":"http://example.com/gitlabhq/gitlab-test.git",
          "ssh_url":"git@example.com:gitlabhq/gitlab-test.git",
          "http_url":"http://example.com/gitlabhq/gitlab-test.git"
        },
        "object_attributes": {
          "id": 301,
          "title": "New API: create/update/delete file",
          "assignee_ids": [51],
          "assignee_id": 51,
          "author_id": 51,
          "project_id": 14,
          "created_at": "2013-12-03T17:15:43Z",
          "updated_at": "2013-12-03T17:15:43Z",
          "updated_by_id": 1,
          "last_edited_at": null,
          "last_edited_by_id": null,
          "relative_position": 0,
          "description": "Create new API for manipulations with repository",
          "milestone_id": null,
          "state_id": 1,
          "confidential": false,
          "discussion_locked": true,
          "due_date": null,
          "moved_to_id": null,
          "duplicated_to_id": null,
          "time_estimate": 0,
          "total_time_spent": 0,
          "time_change": 0,
          "human_total_time_spent": null,
          "human_time_estimate": null,
          "human_time_change": null,
          "weight": null,
          "iid": 23,
          "url": "http://example.com/diaspora/issues/23",
          "state": "opened",
          "action": "open",
          "labels": [{
              "id": 206,
              "title": "API",
              "color": "#ffffff",
              "project_id": 14,
              "created_at": "2013-12-03T17:15:43Z",
              "updated_at": "2013-12-03T17:15:43Z",
              "template": false,
              "description": "API related issues",
              "type": "ProjectLabel",
              "group_id": 41
            }]
        },
        "repository": {
          "name": "Gitlab Test",
          "url": "http://example.com/gitlabhq/gitlab-test.git",
          "description": "Aut reprehenderit ut est.",
          "homepage": "http://example.com/gitlabhq/gitlab-test"
        },
        "assignees": [{
          "name": "User1",
          "username": "user1",
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
        }],
        "assignee": {
          "name": "User1",
          "username": "user1",
          "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
        },
        "labels": [{
          "id": 206,
          "title": "API",
          "color": "#ffffff",
          "project_id": 14,
          "created_at": "2013-12-03T17:15:43Z",
          "updated_at": "2013-12-03T17:15:43Z",
          "template": false,
          "description": "API related issues",
          "type": "ProjectLabel",
          "group_id": 41
        }],
        "changes": {
          "updated_by_id": {
            "previous": null,
            "current": 1
          },
          "updated_at": {
            "previous": "2017-09-15 16:50:55 UTC",
            "current": "2017-09-15 16:52:00 UTC"
          },
          "labels": {
            "previous": [{
              "id": 206,
              "title": "API",
              "color": "#ffffff",
              "project_id": 14,
              "created_at": "2013-12-03T17:15:43Z",
              "updated_at": "2013-12-03T17:15:43Z",
              "template": false,
              "description": "API related issues",
              "type": "ProjectLabel",
              "group_id": 41
            }],
            "current": [{
              "id": 205,
              "title": "Platform",
              "color": "#123123",
              "project_id": 14,
              "created_at": "2013-12-03T17:15:43Z",
              "updated_at": "2013-12-03T17:15:43Z",
              "template": false,
              "description": "Platform related issues",
              "type": "ProjectLabel",
              "group_id": 41
            }]
          }
        }
      }
      """
      |> Jason.decode!()

    template = ~S"""
    {
      "activity": "[{$.project.name}]",
      "title": "",
      "body": "",
      "attachments": [{
        "fields": [{
            "title": "Issue #{$.object_attributes.iid} - {$.object_attributes.title}",
            "value": "{$.object_attributes.url}",
            "style": "Long"
          },
          {
            "title": "Labels",
            "value": "{$.object_attributes.labels[*].title}",
            "style": "Long"
          }
        ]
      }]
    }
    """

    result = Transhook.Transformer.Parser.parse(template, json_params)

    assert result ==
             ~S"""
             {
               "activity": "[Gitlab Test]",
               "title": "",
               "body": "",
               "attachments": [{
                 "fields": [{
                     "title": "Issue #23 - New API: create/update/delete file",
                     "value": "http://example.com/diaspora/issues/23",
                     "style": "Long"
                   },
                   {
                     "title": "Labels",
                     "value": "API",
                     "style": "Long"
                   }
                 ]
               }]
             }
             """
             |> Jason.decode!()
             |> Jason.encode!()
  end
end
